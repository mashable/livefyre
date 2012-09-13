require 'spec_helper'

describe Livefyre do
  context "the default client" do
    it "should raise an exception if the configuration is not set" do
      c = Livefyre.config
      Livefyre.config = nil
      lambda { Livefyre.client }.should raise_exception(Exception)
      Livefyre.config = c
    end

    context "when a configuration is set" do
      before {
        Livefyre.config = {:host => "foo.bar", :key => "foo", :system_token => "123"}
      }

      it "should get a Livefyre::Client" do
        Livefyre.client.should be_a(Livefyre::Client)
      end

      it 'should get the same client instance across multiple calls' do
        Livefyre.client.should eql(Livefyre.client)
      end

      it 'should fetch the config' do
        Livefyre.config.should == {:host => "foo.bar", :key => "foo", :system_token => "123"}
      end
    end
  end
end