module Livefyre
  # Public: Proxy object for an item from a Conversation activity feed
  class Activity
    attr_accessor :id, :user, :conversation, :body, :state, :created_at
    def initialize(client, params = {})
      @client = Livefyre.client
      @params = params
      @id = params["activity_id"]
      @conversation = Conversation.new(@params["lf_conv_id"], @params["article_identifier"])
      @created_at = Time.at(@params["created"]) - Time.at(0).utc_offset
    end

    # Public: Cast this activity to a Comment
    #
    # Return [Comment]
    def comment
      Comment.new(@params["lf_comment_id"], conversation,
        :body => @params["body_text"],
        :user => user,
        :parent_id => @params["lf_parent_comment_id"],
        :author_ip => @params["author_ip"],
        :state => @params["state"]
      )
    end

    # Public: Fetch the user that created this record
    #
    # Returns [User]
    def user
      User.new((@params["lf_jid"] || "").split("@", 2).first, @client, @params["author"],
        :email => @params["author_email"],
        :url => @params["author_url"]
      )
    end

    # Internal: Test if this activity represented a comment
    #
    # Returns [Boolean]
    def comment?
      @params["activity_type"] == "comment-add"
    end
  end
end