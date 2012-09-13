require 'spec_helper'

describe Livefyre::Site do
  context "an instance" do
    subject { Livefyre::Site.new("my.site") }

    describe "#properties" do
      context "on success" do
        before do
          body = {:id => "bar", :api_secret => "secret"}.to_json
          client = double( :get => double(:success? => true, :body => body), :system_token => "x" )
          subject.stub(:client).and_return(client)
          subject.properties
        end

        its(:options) { should == {"id" => "bar", "api_secret" => "secret"} }
        its(:secret) { should == "secret" }
      end

      context "on failure" do
        before do
          client = double( :get => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.properties }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#set_postback_url" do
      context "on success" do
        before do
          client = double( :post => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.set_postback_url("http://foo.bar/").should be true
        end
      end

      context "on failure" do
        before do
          response = double(:success? => false, :body => "")
          client = double( :system_token => "x" )
          client.should_receive(:post).with("/site/my.site/", {:actor_token => "x", :postback_url => "http://foo.bar/"}).and_return(response)
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.set_postback_url("http://foo.bar/") }.to raise_error(Livefyre::APIException)
        end
      end
    end


    describe "#owners" do
      context "on success" do
        before do
          client = double( :get => double(:success? => true, :body => ["foo@bar"].to_json), :system_token => "x" )
          client.should_receive(:user).with("foo").and_return( Livefyre.client.user("foo") )
          subject.stub(:client).and_return(client)
        end

        its(:owners) { should be_a Array }

        its("owners.first") { should be_a Livefyre::User }
        its("owners.first.id") { should == "foo" }
      end

      context "on failure" do
        before do
          client = double( :get => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.owners }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#add_owner" do
      context "on success" do
        before do
          client = double( :post => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.add_owner("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :post => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.add_owner("some user ID") }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#remove_owner" do
      context "on success" do
        before do
          client = double( :delete => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.remove_owner("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :delete => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.remove_owner("some user ID") }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#admins" do
      context "on success" do
        before do
          client = double( :get => double(:success? => true, :body => ["foo@bar"].to_json), :system_token => "x" )
          client.should_receive(:user).with("foo").and_return( Livefyre.client.user("foo") )
          subject.stub(:client).and_return(client)
        end

        its(:admins) { should be_a Array }

        its("admins.first") { should be_a Livefyre::User }
        its("admins.first.id") { should == "foo" }
      end

      context "on failure" do
        before do
          client = double( :get => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.admins }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#add_admin" do
      context "on success" do
        before do
          client = double( :post => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.add_admin("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :post => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.add_admin("some user ID") }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#remove_admin" do
      context "on success" do
        before do
          client = double( :delete => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.remove_admin("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :delete => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key", :jid => "foo@bar.com" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.remove_admin("some user ID") }.to raise_error(Livefyre::APIException)
        end
      end
    end

    it "should have a valid string representation" do
      subject.to_s.should match(/Livefyre::Site.*id='#{subject.id}'/)
    end
  end
end