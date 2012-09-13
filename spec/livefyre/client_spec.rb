require 'spec_helper'

describe Livefyre::Client do
  it "should not initialize without a host" do
    expect { Livefyre::Client.new(:key => "x", :system_token => "x") }.to raise_error Exception
  end

  it "should not initialize without a key" do
    expect { Livefyre::Client.new(:host => "x", :system_token => "x") }.to raise_error Exception
  end

  it "should not initialize without a system token" do
    expect { Livefyre::Client.new(:key => "x", :host => "x") }.to raise_error Exception
  end

  it "should initialize with a key, host, and system token" do
    Livefyre::Client.new(:key => "x", :network => "x", :system_token => "x").should be_a Livefyre::Client
  end

  context "an instance" do
    subject { Livefyre::Client.new(:key => "x", :host => "x", :system_token => "x") }

    describe "#sign" do
      before { @token = subject.sign({:foo => "bar"}) }

      it "should return a string token" do
        @token.should be_a String
      end

      it "should validate" do
        subject.validate(@token).should be_a Hash
      end

      it "should decode" do
        subject.validate(@token)["foo"].should == "bar"
      end
    end

    describe "#user" do
      before { @user = subject.user(1234, "foobar") }
      it "should return a user" do
        @user.should be_a Livefyre::User
      end

      it "should have its ID set" do
        @user.id.should == 1234
      end

      it "should have a reference to this client" do
        @user.client.should == subject
      end
    end

    describe "#set_user_role" do
      context "with a valid role and scope" do
        let(:client) { double "client" }

        before do
          subject.stub(:http_client).and_return(client)
        end

        it "should post an affiliation update for a domain" do
          client.should_receive(:post).with("/api/v1.1/private/management/user/123@x/role/", {:affiliation=>"admin", :lftoken=>"x", :domain_wide=>1}).and_return( double(:success? => true) )
          subject.set_user_role(123, "admin", "domain").should == true
        end

        context "when updating a site affiliation" do
          it "should fail if no scope ID is passed" do
            client.should_not_receive(:post)
            expect { subject.set_user_role(123, "admin", "site") }.to raise_error Exception
          end

          it "should post an affiliation update for a site" do
            client.should_receive(:post).with("/api/v1.1/private/management/user/123@x/role/", {:affiliation=>"admin", :lftoken=>"x", :site_id=>123}).and_return( double(:success? => true) )
            subject.set_user_role(123, "admin", "site", 123).should == true
          end
        end

        context "when updating a conversation affiliation" do
          it "should fail if no scope ID is passed" do
            client.should_not_receive(:post)
            expect { subject.set_user_role(123, "admin", "conv") }.to raise_error Exception
          end

          it "should post an affiliation update for a site" do
            client.should_receive(:post).with("/api/v1.1/private/management/user/123@x/role/", {:affiliation=>"admin", :lftoken=>"x", :conv_id=>123}).and_return( double(:success? => true) )
            subject.set_user_role(123, "admin", "conv", 123).should == true
          end
        end

        context "when it fails" do
          it "should raise an exception" do
            client.should_receive(:post).and_return( double(:success? => false, :body => "Failure due to zombie outbreak") )
            expect { subject.set_user_role(123, "admin", "domain") }.to raise_error(Livefyre::APIException)
          end
        end
      end
    end

    it "should have a valid string representation" do
      subject.to_s.should match(/Livefyre::Client/)
    end
  end
end
