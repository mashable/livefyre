require 'spec_helper'

describe Livefyre::User do
  describe "#initialize" do
    context "when no client is passed" do
      it "should use the default client" do
        Livefyre::User.new(123).client.should eql(Livefyre.client)
      end
    end

    context "when a client is passed" do
      it "should use the passed client" do
        client = Livefyre::Client.new(:host => "x", :key => "x", :system_token => "x")
        Livefyre::User.new(123, client).tap do |user|
          user.client.should eql client
          user.client.should_not eql Livefyre.client
        end
      end
    end
  end

  describe "::get_user_id" do
    it "should return an ID when passed a string" do
      Livefyre::User.get_user_id("foobar").should == "foobar"
    end

    it "should return an ID when passed a User" do
      Livefyre::User.get_user_id( Livefyre::User.new("foobar") ).should == "foobar"
    end

    it "should return an ID when passed an integer" do
      Livefyre::User.get_user_id(123).should == 123
    end

    it "should raise an exception when passed an invalid value" do
      expect { Livefyre::User.get_user_id(nil) }.to raise_error("Invalid user ID")
    end
  end

  describe "::get_user" do
    context "should return a user when passed a user ID" do
      subject { Livefyre::User.get_user("foobar", Livefyre.client) }
      it { should be_a Livefyre::User }
      its(:id) { should == "foobar" }
      its(:client) { should == Livefyre.client }
    end

    context "should return a user when passed a User object" do
      subject { Livefyre::User.get_user( Livefyre::User.new("123", Object.new) , Livefyre.client) }
      it { should be_a Livefyre::User }
      its(:id) { should == "123" }
      its(:client) { should == Livefyre.client }
    end

    it "should raise an exception when passed an invalid value" do
      expect { Livefyre::User.get_user( nil , Livefyre.client ) }.to raise_error("Invalid user ID")
    end
  end

  context "an instance" do
    subject { Livefyre::User.new(123) }

    its(:jid) { should == "123@foo.bar" }
    its(:token) { should be_a String }

    it "should decode a token" do
      subject.client.validate(subject.token)["domain"].should == subject.client.host
    end

    context "#push" do
      context "on success" do
        before do
          client = double("client")
          client
            .should_receive(:post)
            .with("/profiles/?actor_token=#{subject.client.system_token}&id=#{subject.id}", {:data => {:some => "data"}.to_json})
            .and_return(double(:success? => true))
          subject.client.stub(:http_client).and_return(client)
        end

        it "returns true" do
          subject.push(:some => "data").should == true
        end
      end

      context "on failure" do
        before do
          client = double("client")
          client
            .should_receive(:post)
            .with("/profiles/?actor_token=#{subject.client.system_token}&id=#{subject.id}", {:data => {:some => "data"}.to_json})
            .and_return(double(:success? => false, :body => "error"))
          subject.client.stub(:http_client).and_return(client)
        end

        it "raises an APIException" do
          expect { subject.push(:some => "data") }.to raise_error(Livefyre::APIException)
        end
      end
    end

    context "#refresh" do
      let(:client) { double("client") }

      it "should post to the ping-to-pull endpoint" do
        subject.client.should_receive(:post).with("/api/v3_0/user/#{subject.id}/refresh", {:lftoken => subject.client.system_token})
          .and_return( double(:success? => true) )
        subject.refresh.should == true
      end

      it "should raise an exception when it fails to post to the ping-to-pull endpoint" do
        subject.client.should_receive(:post).with("/api/v3_0/user/#{subject.id}/refresh", {:lftoken => subject.client.system_token})
          .and_return( double(:success? => false, :body => "Temporal failure in the primary quantum induction matrix") )
        expect { subject.refresh.should }.to raise_error(Livefyre::APIException)
      end
    end

    it "should have a valid string representation" do
      subject.to_s.should match(/Livefyre::User.*id='#{subject.id}'/)
    end
  end
end
