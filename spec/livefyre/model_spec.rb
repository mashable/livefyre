require 'spec_helper'

if defined? Livefyre::Model
  class BaseUser
    include Livefyre::Model
    attr_accessor :id
    attr_accessor :email

    def email=(email)
      @email = email
      @email_changed = true
    end

    def email_changed?
      @email_changed
    end

    def save
      self.class.instance_variable_get("@callbacks").each do |callback|
        send callback
      end
    end

    def self.after_save(callback)
      @callbacks ||= []
      @callbacks.push callback
    end
  end

  class UserWithDefer < BaseUser
    livefyre_user :update_on => [:email], :defer => true
  end

  class UserWithoutDefer < BaseUser
    livefyre_user :update_on => [:email]
  end

  class UserWithCustomId < BaseUser
    livefyre_user :id => :custom_id, :update_on => [:email]

    def custom_id
      "foobar"
    end
  end

  describe Livefyre::Model do
    context "when saving" do
      it "should not do anything if the watched fields haven't changed" do
        u = UserWithDefer.new
        u.should_not_receive(:refresh_livefyre)
        u.save
      end

      it "should call refresh when fields have changed" do
        u = UserWithDefer.new
        u.email = "new@email.com"
        u.should_receive(:refresh_livefyre)
        u.save
      end

      context "an instance that is set to defer" do
        let(:user) { UserWithDefer.new }

        it "should invoke Resque when refresh_livefyre is called" do
          Resque.should_receive(:enqueue).with(Livefyre::Model::RequestPull, user.id)
          user.email = "new@email.com"
          user.save
        end
      end

      context "an instance that is not set to defer" do
        let(:user) { UserWithoutDefer.new }

        it "should invoke Livefyre::Model::RequestPull when refresh_livefyre is called" do
          Livefyre::Model::RequestPull.should_receive(:perform).with(user.id)
          user.email = "new@email.com"
          user.save
        end
      end

      context "an instance with a custom ID" do
        let(:user) { UserWithCustomId.new }

        it "should invoke Livefyre::Model::RequestPull when refresh_livefyre is called" do
          Livefyre::Model::RequestPull.should_receive(:perform) #.with(user.custom_id)
          user.email = "new@email.com"
          user.save
        end
      end
    end
  end
end