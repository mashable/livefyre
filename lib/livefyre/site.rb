module Livefyre
  # Public: Exception representing a failure to validate a signature
  class InvalidSignatureException < Exception; end

  # Public: An object representing a Livefyre site belonging to a Livefyre domain
  class Site
    attr_accessor :client, :secret, :options, :id

    # Public: Create a new Site
    def initialize(id, client = nil, options = {})
      @id = id
      @client = client || Livefyre.client
      @options = options
      @secret = options["api_secret"]
    end

    # Public: Search conversations on this domain
    #
    # query   - string to query for
    # options - [Hash] of options
    # :fields - list of fields to search. Default [:article, :title, :body]
    # :sort   - Sort order for options. Valid values are [:relevance, :created, :updated, :hotness, :ncomments]. Default is :relevance
    # :fields - List of fields to return in the result. Valid values are: article_id, site_id, domain_id, title, published, updated, author, url, ncomment, nuser, annotation, nlp, hotness, hottest_value, hottest_time, peak, peak_value, peak_time, comments:5, users:5, comment_state, hit_field, dispurl, relevancy
    # :max    - Maximum number of fields to return
    # :since  - [DateTime] Minimum date of results to return
    # :until  - [DateTime] Maximum date of results to return
    # :page   - Page of results to fetch. Default 1.
    #
    # Returns [Array<Conversation>] An array of matching conversations
    # Raises [APIException] when response is not valid
    def search_conversations(query, options = {})
      options[:sites] = [self]
      Domain.new(@client).search_conversations(query, options)
    end

    # Public: Get a list of properties for this site
    #
    # reload - Force a reload when set
    #
    # Returns [Hash] Site properties
    # Raises [APIException] when response is not valid
    def properties(reload = false)
      return @options unless @options.nil? or @options.empty? or reload
      response = client.get "/site/#{id}/", {:actor_token => client.system_token}
      if response.success?
        @options = JSON.parse response.body
        @secret = options["api_secret"]
        @options
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Fetches a feed of the site's latest activity.
    #
    # since_id - [Integer] If provided, will return feed items after the given feed item.
    #
    # Returns [Array<Activity>] List of feed activities
    def feed(since_id = nil)
      reload if secret.nil?
      timestamp = Time.now.utc.to_i
      sig = Base64.encode64 HMAC::SHA1.new(Base64.decode64 secret).update("sig_created=%s" % timestamp).digest
      url = "/%s/" % ["site", id, "sync", since_id].compact.join("/")
      response = client.get url, {:sig_created => timestamp, :sig => sig}
      if response.success?
        payload = JSON.parse(response.body).map {|item| Activity.new(client, item) }
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Fetches the latest comments from this site
    #
    # since_id - [Integer] If provided, will return feed items after the given comment.
    #
    # Returns: [Array<Comment>] List of comment
    def comments(since = nil)
      feed(since).select(&:comment?).map(&:comment)
    end

    # Public: Reload this site's properties from Livefyre
    #
    # Returns self
    def reload
      properties(true)
      self
    end

    # Public: Set the postback URL for actions on this site
    #         See: https://github.com/Livefyre/livefyre-docs/wiki/Accessing-Site-Comment-Data
    #
    # url - [String] URL to use as the postback URL for actions
    #
    # Returns [Bool] true on success
    # Raises: [APIException] when response is not valid
    def set_postback_url(url)
      response = client.post "/site/#{id}/", {:actor_token => client.system_token, :postback_url => url}
      if response.success?
        properties(true) rescue APIException nil
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Retrieve a list of owners associated with this site
    #
    # Returns [Array<Livefyre::User>] A list of {Livefyre::User users}
    # Raises: APIException when response is not valid
    def owners
      response = client.get "/site/#{id}/owners/", {:actor_token => client.system_token}
      if response.success?
        JSON.parse(response.body).map do |u|
          client.user u.split("@", 2).first
        end
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Adds a user to the list of owners for this site
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def add_owner(user)
      uid = User.get_user_id(user)
      response = client.post "/site/#{id}/owners/?actor_token=#{CGI.escape client.system_token}", {:jid => client.jid(uid)}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Removes a user from the list of owners for this site
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def remove_owner(user)
      user = User.get_user(user, client)
      response = client.delete "/site/#{id}/owner/#{user.jid}/?actor_token=#{CGI.escape client.system_token}"
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Retrieve a list of owners associated with this site
    #
    # Returns [Array<Livefyre::User>] A list of {Livefyre::User users}
    # Raises: [APIException] when response is not valid
    def admins
      response = client.get "/site/#{id}/admins/", {:actor_token => client.system_token}
      if response.success?
        JSON.parse(response.body).map do |u|
          client.user u.split("@", 2).first
        end
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Adds a user to the list of admins for this site
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def add_admin(user)
      user = User.get_user(user, client)
      response = client.post "/site/#{id}/admins/?actor_token=#{CGI.escape client.system_token}", {:jid => user.jid}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Removes a user from the list of admins for this site
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def remove_admin(user)
      user = User.get_user(user, client)
      response = client.delete "/site/#{id}/admin/#{user.jid}/?actor_token=#{CGI.escape client.system_token}"
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Create a conversation collection on this site
    #
    # Returns [Conversation]
    def create_conversation(article_id, title, link, tags = nil)
      Conversation.create(client, article_id, title, link, tags)
    end

    # Internal: Returns a cleaner string representation of this object
    #
    # Returns [String] representation of this class
    def to_s
      "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(14, "0")} id='#{id}' secret='#{secret}' options=#{options.inspect}>"
    end

    # Public: Validate a signature as passed by the Livefyre postback service
    #
    # Returns [Bool]
    # Raises [InvalidSignatureException] on failure
    def self.validate_signature(sig, created_at, secret)
      raise InvalidSignatureException.new "Missing sig" if sig.nil?
      raise InvalidSignatureException.new "Missing sig_created" if created_at.nil?
      raise InvalidSignatureException.new "Missing site key" if secret.nil?

      t = Time.at(created_at.to_i)
      utc = Time.utc(t.year, t.month, t.day, t.hour + 7, t.min, t.sec)
      # raise InvalidSignatureException.new "Invalid timestamp" if (Time.now - utc).abs > 300  # Timestamp is more than 5 minutes out of date.

      check = Base64.encode64 HMAC::SHA1.new(Base64.decode64 secret).update("sig_created=%s" % created_at).digest
      raise InvalidSignatureException.new "Invalid signature" if check != sig
      return sig == check
    end
  end
end