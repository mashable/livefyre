module Livefyre
  # Public: Proxy object for a Livefyre [Conversation] (also called a Collection)
  class Conversation
    attr_accessor :id, :article_id
    def initialize(id, article_id)
      @id = id
      @article_id = article_id
      @client = Livefyre.client
    end

    # Public: Fetch a list of comments from a conversation
    #         TODO: Not currently working.
    def comments
      response = @client.bootstrap.get "/bs3/#{@client.options[:domain]}/#{@client.options[:network]}/#{@client.options[:site_id]}/#{Base64.encode64 @article_id}/init"
      if response.success?
        JSON.parse response.body
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Update this collection with new metadata
    #
    # Returns [Bool] true on success
    # Raises [APIException] on failure
    def update(title, link, tags = nil)
      meta = self.class.collectionMeta(@client, @article_id, title, link, tags)
      response = @client.quill.post "/api/v3.0/site/#{@client.options[:site_id]}/collection/update/", {:collectionMeta => meta, :articleId => @article_id}.to_json
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Create a comment on this conversation
    #
    # user - [User] to create the comment as
    # body - [String] body of the content
    #
    # Returns [Comment]
    def create_comment(user, body)
      Comment.create(@client, user, self, body)
    end

    # Public: Follow this conversation as the passed user
    #
    # user - [User] to follow the conversation as
    #
    # Returns [Boolean] true on success
    # Raises [APIException] on failure
    def follow_as(user)
      response = @client.quill.post "/api/v3.0/collection/10584292/follow/", :lftoken => user.token, :collectionId => @id
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Unfollow this conversation as the passed user
    #
    # user - [User] to unfollow the conversation as
    #
    # Returns [Boolean] true on success
    # Raises [APIException] on failure
    def unfollow_as(user)
      response = @client.quill.post "/api/v3.0/collection/10584292/unfollow/", :lftoken => user.token, :collectionId => @id
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Create a new collection
    #
    # client     - [Client] identifying the site to create the collection on
    # article_id - [String] ID to use to identify this article
    # title      - [String] Article title
    # link       - [String] Article link
    # tags       - [String, Array] Article tags
    #
    # Returns [Conversation]
    def self.create(client, article_id, title, link, tags = nil)
      meta = collectionMeta(client, article_id, title, link, tags)
      response = client.quill.post "/api/v3.0/site/#{client.options[:site_id]}/collection/create", {:collectionMeta => meta, :articleId => article_id}.to_json
      if response.success?
        body = JSON.parse(response.body)
        Conversation.new(body["data"]["collectionId"], article_id)
      else
        error = JSON.parse(response.body)
        raise APIException.new(error["msg"])
      end
    end

    # Internal: Generate a signed collectionMeta
    #
    # client     - [Client] identifying the site to create the collection on
    # title      - [String] Article title
    # link       - [String] Article link
    # tags       - [String, Array] Article tags
    #
    # Returns [String] signed token
    def self.collectionMeta(client, article_id, title, link, tags)
      tag_str = case tags
      when Array
        tags.join ","
      when String
        tags
      when nil
        nil
      else
        raise "Invalid value given for tags: must be Array, String, or nil"
      end

      begin
        URI.parse(link)
      rescue URI::InvalidURIError => e
        raise "Invalid value for link: #{e.message}"
      end

      metadata = {
        :title => title,
        :url   => link,
        :articleId => article_id,
        :tags  => tag_str || "",
      }

      JWT.encode(metadata, client.site_key)
    end
  end
end