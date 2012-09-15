module Livefyre
  # Public: Interface for dealing with Livefyre users by User ID.
  class User
    attr_accessor :id, :display_name

    # Public: Create a new Livefyre User proxy.
    #
    # id           - [String] ID of the user to proxy
    # client       - [Livefyre::Client] an instance of Livefyre::Client. If nil, the default client is used.
    # display_name - [String] The display name for this user (optional)
    def initialize(id, client = nil, display_name = nil, args = {})
      @id = id
      @client = client || Livefyre.client
      @display_name = display_name
      @options = args
    end

    def client=(client)
      @client = client
    end

    # Internal - Fetch an internal Jabber-style ID for this user
    #
    # Returns [String] representation of this user
    def jid
      "#{id}@#{@client.host}"
    end

    # Public: Creates a signed JWT token for this user
    #
    # max_age - [Integer] Expiry time for this token in seconds (default: 86400)
    #
    # Returns [String] token
    def token(max_age = 86400)
      data = {
        :domain => @client.host,
        :user_id => id,
        :expires => Time.now.to_i + max_age
      }.tap do |opts|
        opts[:display_name] = @display_name unless @display_name.nil?
      end
      JWT.encode(data, @client.key)
    end

    # Public: Update this user's profile on Livefyre
    #
    # data - [Hash] A hash of user data as defined by the Livefyre user profile schema
    #
    # Returns [Bool] true on success
    # Raises [APIException] if the request failed
    def push(data)
      result = @client.post "/profiles/?actor_token=#{CGI.escape @client.system_token}&id=#{id}", {:data => data.to_json}
      if result.success?
        true
      else
        raise APIException.new(result.body)
      end
    end

    # Public: Invoke Livefyre ping-to-pull to refresh this user's data
    #
    # Returns [Bool] true on success
    # Raises [APIException] if the request failed
    def refresh
      result = @client.post "/api/v3_0/user/#{id}/refresh", {:lftoken => @client.system_token}
      if result.success?
        true
      else
        raise APIException.new(result.body)
      end
    end

    # Public: Coerce a string or [User] into a user ID
    #
    # userish - [String/User/Int]A [User] or user ID
    #
    # Returns [String] User ID
    # Raises Exception when value can't be coerced
    def self.get_user_id(userish)
      case userish
      when String
        userish.split("@", 2).first
      when Fixnum
        userish
      when User
        userish.id
      else
        raise "Invalid user ID"
      end
    end

    # Public: Fetch a Livefyre::User from a user record or ID
    #
    # userish - [String/User/Int] A User or user ID
    # client  - [Livefyre::Client] Client to bind to the User record
    #
    # Returns [User]
    def self.get_user(userish, client)
      case userish
      when User
        userish.client = client
        userish
      else
        new get_user_id(userish), client
      end
    end

    # Internal: Returns a cleaner string representation of this object
    #
    # Returns [String] representation of this class
    def to_s
      "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(14, "0")} id='#{id}' display_name='#{display_name}'>"
    end
  end
end