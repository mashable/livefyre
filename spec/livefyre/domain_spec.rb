require 'spec_helper'

describe Livefyre::Domain do
  context "an instance" do
    subject { Livefyre::Domain.new }

    describe "#sites" do
      context "on success" do
        before do
          client = double( :get => double(:success? => true, :body => [{:id => "foo.com"}].to_json), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        its(:sites) { should be_a Array }

        its("sites.first") { should be_a Livefyre::Site }
        its("sites.first.id") { should == "foo.com" }
      end

      context "on failure" do
        before do
          client = double( :get => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.sites }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#users" do
      context "on success" do
        before do
          client = double( :get => double(:success? => true, :body => [{:id => "foo"}].to_json), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        its(:users) { should be_a Array }

        its("users.first") { should be_a Livefyre::User }
        its("users.first.id") { should == "foo" }
      end

      context "on failure" do
        before do
          client = double( :get => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.users }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#add_user" do
      context "on success" do
        before do
          client = double( :post => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.add_user({"id" => "valid ID"}).should be true
        end
      end

      context "on failure" do
        before do
          client = double( :post => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.add_user({"id" => "valid ID"}) }.to raise_error(Livefyre::APIException)
        end

        it "should raise an exception when passed an invalid ID" do
          expect { subject.add_user({"bad_id" => "invalid ID"}) }.to raise_error("Invalid ID")
        end
      end
    end

    describe "#create_site" do
      context "on success" do
        before do
          client = double( :post => double(:success? => true, :body => {"id" => "foo"}.to_json), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
          @site = subject.create_site("some URL")
        end

        it "should return a Site" do
          @site.should be_a Livefyre::Site
        end

        it "should be prepopulated with the values we just passed" do
          @site.id.should == "foo"
        end
      end

      context "on failure" do
        before do
          client = double( :post => double(:success? => false, :body => ""), :system_token => "x" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.create_site("some_url") }.to raise_error(Livefyre::APIException)
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
          client = double( :put => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.add_owner("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :put => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key" )
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
          client = double( :delete => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.remove_owner("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :delete => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key" )
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
          client = double( :post => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.add_admin("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :post => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key" )
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
          client = double( :delete => double(:success? => true), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
        end

        it "should return true" do
          subject.remove_admin("some ID").should be true
        end
      end

      context "on failure" do
        before do
          client = double( :delete => double(:success? => false, :body => ""), :system_token => "x", :host => "some_host", :key => "some_key" )
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.remove_admin("some user ID") }.to raise_error(Livefyre::APIException)
        end
      end
    end

    describe "#set_pull_url" do
      context "when it succeeds" do
        before do
          response = double(:success? => true)
          client = double(:post => response, :system_token => "x")
          subject.stub(:client).and_return(client)
          @response = subject.set_pull_url 'http://foo.bar/{id}/'
        end

        it "should return true" do
          @response.should == true
        end
      end

      context "when it fails" do
        before do
          response = double(:success? => false, :body => "failure")
          client = double(:post => response, :system_token => "x")
          subject.stub(:client).and_return(client)
        end

        it "should raise an exception" do
          expect { subject.set_pull_url 'http://foo.bar/{id}/' }.to raise_error(Livefyre::APIException)
        end
      end
    end

    it "should have a valid string representation" do
      subject.to_s.should match(/Livefyre::Domain.*host='#{subject.client.host}'/)
    end
  end
end