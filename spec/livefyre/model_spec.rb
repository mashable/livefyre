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

  class UserWithBlock < BaseUser
    attr_accessor :foo
    livefyre_user :update_on => [:email] do |o, id|
      o.foo = 1
    end
  end

  class UserWithoutBlock < BaseUser
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
        u = UserWithoutBlock.new
        u.should_not_receive(:refresh_livefyre)
        u.save
      end

      it "should call refresh when fields have changed" do
        u = UserWithoutBlock.new
        u.email = "new@email.com"
        u.should_receive(:refresh_livefyre)
        u.save
      end

      context "an instance that is set to call a block" do
        let(:user) { UserWithBlock.new }

        it "should invoke the passed block when refresh_livefyre is called" do
          Livefyre::User.should_not_receive(:refresh)
          user.email = "new@email.com"
          user.save
          user.foo.should == 1
        end
      end

      context "an instance that is not set to defer" do
        let(:user) { UserWithoutBlock.new }

        it "should invoke Livefyre::Model::RequestPull when refresh_livefyre is called" do
          Livefyre::User.should_receive(:refresh)
          user.email = "new@email.com"
          user.save
        end
      end

      context "an instance with a custom ID" do
        let(:user) { UserWithCustomId.new }

        it "should invoke Livefyre::Model::RequestPull when refresh_livefyre is called" do
          Livefyre::User.should_receive(:refresh)
          user.email = "new@email.com"
          user.save
        end
      end
    end
  end
end