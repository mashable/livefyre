module Livefyre
  # Public: Proxy object for a [Comment] on a [Livefyre::Conversation]
  class Comment
    private
    SOURCES       = %w(Livefyre Twitter Twitter Facebook Livefyre Livefyre Facebook Twitter Livefyre)
    VISIBILITIES  = %w(None Everyone Owner Group)
    CONTENT_TYPES = %w(Message Opinion)
    PERMISSIONS   = %w(Global Network Site Collection CollectionRule)
    REASONS       = %w(disagree spam offensive off-topic)

    public

    attr_accessor :id, :body, :user, :parent_id, :ip, :conversation, :created_at
    def initialize(id, conversation, options = {})
      @id           = id
      @body         = options[:body]
      @user         = options[:user]
      @parent_id    = options[:parent_id]
      @ip           = options[:author_ip]
      @conversation = conversation
      @created_at   = options[:created_at]
      @client       = options[:client] || Livefyre.client
      @options      = options
    end

    # Public: Flag a comment
    #
    # reason - one of [disagree, spam, offensive, off-topic]
    # notes  - String containing the reason for the flag
    # email  - email address of the flagger
    # user   - [User] If set, will include the user token for validation of the flag
    def flag(reason, notes, email, user = nil)
      raise "invalid reason" unless REASONS.include? reason
      payload = {
        :message_id => @id,
        :collection_id => @conversation.id,
        :flag => reason,
        :notes => notes,
        :email => email
      }
      payload[:lftoken] = user.token if user
      response = client.quill.post "/api/v3.0/message/25818122/flag/#{reason}/", payload.to_json
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Delete this comment
    #
    # Returns [Boolean] true on success
    # Raises [APIException] on failure
    def delete!
      response = client.quill.post "/api/v3.0/message/#{id}/delete", {:lftoken => @client.system_token}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Update this comment's content
    #
    # Returns [Boolean] true on success
    # Raises [APIException] on failure
    def update(body)
      response = client.quill.post "/api/v3.0/message/#{id}/edit", {:lftoken => @client.system_token, :body => body}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Get the comment source as a string.
    #         Currently only populated when created via ::create
    #
    # Returns [Enum<SOURCES>]
    def source
      source_id ? SOURCES[source_id] : nil
    end

    # Public: Get the comment source as an integer.
    #         Currently only populated when created via ::create
    #
    # Returns [Integer]
    def source_id
      @options[:source]
    end

    # Public: Get the comment visibility as a string.
    #         Currently only populated when created via ::create
    #
    # Returns [Enum<VISIBILITIES>]
    def visibility
      visibility_id ? VISIBILITIES[visibility_id] : nil
    end

    # Public: Get the comment visibility as an integer.
    #         Currently only populated when created via ::create
    #
    # Returns [Integer]
    def visibility_id
      @options[:visibility]
    end

    # Public: Get the comment content type as a string.
    #         Currently only populated when created via ::create
    #
    # Returns [Enum<CONTENT_TYPES>]
    def content_type
      content_type_id ? CONTENT_TYPES[content_type_id] : nil
    end

    # Public: Get the comment visibility as an integer.
    #         Currently only populated when created via ::create
    #
    # Returns [Integer]
    def content_type_id
      @options[:type]
    end

    # Public: Likes a comment as the passed user
    #
    # Returns [Boolean] true on success
    # Raises [APIException] on failure
    def like!(user)
      response = @client.quill.post "/api/v3.0/message/#{id}/like/", {:collection_id => conversation.id, :lftoken => user.token}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Unlikes a comment as the passed user
    #
    # Returns [Boolean] true on success
    # Raises [APIException] on failure
    def unlike!(user)
      response = @client.quill.post "/api/v3.0/message/#{id}/unlike/", {:collection_id => conversation.id, :lftoken => user.token}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: create a new comment on a conversation
    #
    # client       - [Client] representing the site to use when creating the conversation
    # user         - [User] to create the comment as
    # conversation - [Conversation] to create
    # body         - [String] Comment body
    #
    # Returns [Comment]
    # Raises [APIException] when the API call fails
    def self.create(client, user, conversation, body, reply_to = nil)
      response = client.quill.post "/api/v3.0/collection/#{conversation.id}/post/", {:lftoken => user.token, :body => body, :_bi => client.identifier, :parent_id => reply_to}
      if response.success?
        puts JSON.parse(response.body).inspect
        data = JSON.parse(response.body)["data"]

        data["messages"].map do |entry|
          c = entry["content"]
          Comment.new(c["id"], conversation, {
            :body         => c["bodyHtml"],
            :parent_id    => c["parentId"],
            :user         => User.new(c["authorId"], data["authors"].first.last["displayName"], data["authors"].first.last),
            :created_at   => Time.at(c["createdAt"]),
            :source       => entry["source"],
            :visibility   => entry["vis"],
            :client       => client,
            :type         => entry["type"]
          })
        end.first
      else
        raise APIException.new(response.body)
      end
    end

    # Internal: Returns a cleaner string representation of this object
    #
    # Returns [String] representation of this class
    def to_s
      "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(14, "0")} id='#{id}' options=#{@options.inspect}>"
    end
  end
end