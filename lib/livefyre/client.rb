module Livefyre
  # Public: Primary interface to the Livefyre API
  class Client
    extend Forwardable
    # Public: Valid roles for #set_user_role
    ROLES = %w(admin member none outcast owner)

    # Public: Valid scopes for #set_user_role
    SCOPES = %w(domain site conv)

    attr_accessor :host, :key, :options, :system_token, :http_client, :site_key, :quill, :stream, :bootstrap

    def_delegators :http_client, :get, :post, :delete, :put

    # Public: Create a new Livefyre client.
    #
    # options - [Hash] array of options to pass to the client for initialization
    # :host         - your Livefyre network_host
    # :key          - your Livefyre network_key
    # :system_token - your Livefyre long-lived system user key
    def initialize(options = {})
      @options = options.clone
      @host = options.delete(:network) || options.delete(:host)
      raise "Invalid host" if @host.nil?
      @http_client = Faraday.new(:url => "http://#{@host}")
      @quill = Faraday.new(:url => "http://quill.#{@host}")
      @stream = Faraday.new(:url => "http://stream.#{@host}")
      @bootstrap = Faraday.new(:url => "http://bootstrap.#{@host}")
      @site_key = options[:site_key]

      @key = options.delete(:secret) || options.delete(:key) || options.delete(:network_key)
      raise "Invalid secret key" if @key.nil?

      @system_token = options.delete(:system_token)
      raise "Invalid system token" if @system_token.nil?
    end

    # Public: Sign a data structure with this client's network key.
    #
    # Returns [String] A signed JWT token
    def sign(data)
      JWT.encode(data, @key)
    end

    # Public: Validates and decodes a JWT token
    #
    # Returns [Hash] A hash of data passed from the token
    # Raises [JWT::DecodeError] if invalid token contents or signature
    def validate(data)
      JWT.decode(data, @key)
    end

    # Public: Create a {Livefyre::User} with this client's credentials.
    #
    # uid          - the user ID to create a Livefyre user for. This should be the ID used to reference this user in Livefyre's system.
    # display_name - the displayed name for this user. Optional.
    #
    # Returns [Livefyre::User]
    def user(uid, display_name = nil)
      User.new(uid, self, display_name)
    end

    # Public: Sets a user's role (affiliation) in a given scope.
    #
    # user_id   - The user ID (without the host) to set roles for
    # role      - The {ROLES role} to set.
    # scope     - The {SCOPES scope} for which to set this role.
    # scope_id  - In the case that the given scope requires identification, specifies which scope to operate on.
    #
    # Examples
    #
    #   set_user_role(1234, "owner", "domain")
    #   set_user_role(1234, "moderator", "site", site_id)
    #   set_user_role(1234, "moderator", "conv", conversation_id)
    #
    #
    # Returns [Bool] true on success
    # Raises APIException if the request failed
    def set_user_role(user_id, role, scope = 'domain', scope_id = nil)
      raise "Invalid scope" unless SCOPES.include? scope
      raise "Invalid role" unless ROLES.include? role

      post_data = {
        :affiliation => role,
        :lftoken => system_token,
      }
      case scope
      when "domain"
        post_data[:domain_wide] = 1
      when "conv"
        raise "Invalid scope_id" if scope_id.nil?
        post_data[:conv_id] = scope_id
      when "site"
        raise "Invalid scope_id" if scope_id.nil?
        post_data[:site_id] = scope_id
      end
      result = post "/api/v1.1/private/management/user/#{jid(user_id)}/role/", post_data
      if result.success?
        true
      else
        raise APIException.new(result.body)
      end
    end

    # Public: Transform the given ID into a jid
    #
    # id - a string value to compose the JID with
    #
    # Returns [String] JID
    def jid(id)
      "%s@%s" % [id, host]
    end

    # Internal: Identifier to use to uniquely identify this client.
    #
    # Returns string ID
    def identifier
      @identifier ||= "RubyLib-#{Process.pid}-#{local_ip}-#{object_id}"
    end

    # Internal: Returns a cleaner string representation of this object
    #
    # Returns [String] representation of this class
    def to_s
      "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(14, "0")} host='#{host}' key='#{key}'>"
    end

    private

    def local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end
  end
end