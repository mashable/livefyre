require 'jwt'
require 'faraday'
require 'forwardable'

# Public: Toplevel Livefyre namespace
module Livefyre
  # Public: Exception thrown when the Livefyre API does not return a success value
  #         #message will be the response body from the Livefyre API.
  class APIException < ::Exception; end

  # Public: Set the default configuration object for Livefyre clients
  #
  # Returns [nil]
  def self.config=(config)
    config.keys.each do |key|
      config[(key.to_sym rescue key) || key] = config.delete(key)
    end if config.is_a? Hash
    @@config = config
    @@client = nil
  end

  # Public: Get the configuration object for default clients
  #
  # Returns [Hash] configuration hash
  def self.config
    @@config
  end

  # Public: Retreive a singleton instance of the Livefyre client
  #
  # Returns [Livefyre::Client] instance configured with the default settings
  # Raises Exception if #config is nil
  def self.client
    raise "Invalid configuration" if @@config.nil?
    @@client ||= Livefyre::Client.new(@@config)
  end
end

require File.expand_path("livefyre/client", File.dirname(__FILE__))
require File.expand_path("livefyre/user", File.dirname(__FILE__))
require File.expand_path("livefyre/domain", File.dirname(__FILE__))
require File.expand_path("livefyre/site", File.dirname(__FILE__))

if defined?(Rails)
  require File.expand_path("livefyre/controller_extensions", File.dirname(__FILE__))
  require File.expand_path("livefyre/helpers", File.dirname(__FILE__))
  require File.expand_path("../railties/railtie", File.dirname(__FILE__))
  require File.expand_path("livefyre/engine", File.dirname(__FILE__))
end