module Livefyre
  # Public: View helpers for Livefyre
  module Helpers

    # Public: Add a Livefyre comment form to this page.
    #
    # id      - [String, Integer] identifier to use for this conversation. Likely a post ID.
    # title   - [String] Title of this post or conversation
    # link    - [String] Link to this post or conversation
    # tags    - [Array, String] Optional array or comma-delimited list of tags on this conversation.
    # options - [Hash] Additional options to pass to the created div tag.
    #
    # Returns [String] div element for insertion into your view
    def livefyre_comments(id, title, link, tags = nil, options = {})
      meta = livefyre_conversation_metadata(id, title, link, tags)
      options.merge!(
        :id => "livefyre_comments",
        :data => {
          :checksum => meta[:checksum],
          :"collection-meta" => meta[:collectionMeta],
          :"site-id" => meta[:siteId],
          :"article-id" => meta[:articleId],
          :network => Livefyre.client.host,
          :root => Livefyre.config[:domain]
        }
      )
      content_tag(:div, "", options)
    end

    private

    # Internal: Generate a metadata hash from the given attributes.
    #
    # Returns [Hash]
    def livefyre_conversation_metadata(id, title, link, tags)
      tags = tags.join(",") if tags.is_a? Array

      metadata = {
        :title => title,
        :url   => link,
        :tags  => tags
      }
      metadata[:checksum] = Digest::MD5.hexdigest(metadata.to_json)
      metadata[:articleId] = id
      post_meta = JWT.encode(metadata, Livefyre.config[:site_key])

      {
        :el => "livefyre_comments",
        :checksum => metadata[:checksum],
        :collectionMeta => post_meta,
        :siteId => Livefyre.config[:site_id],
        :articleId => id.to_s
      }
    end
  end
end