module Livefyre
  # Public: Proxy for a Livefyre domain resource
  class Domain
    attr_accessor :client

    def initialize(client = nil)
      @client = client || Livefyre.client
    end

    # Public: Get a list of sites for this domain
    #
    # Returns [Array<Site>] An array of {Site sites}
    # Raises [APIException] when response is not valid
    def sites
      response = client.get "/sites/?actor_token=#{CGI.escape client.system_token}"
      if response.success?
        JSON.parse(response.body).map do |site|
          Site.new(site["id"], client, site)
        end
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Get a list of users on this domain
    #
    # Returns [Array<User>] An array of {User users}
    # Raises [APIException] when response is not valid
    def users
      response = client.get "/profiles/?actor_token=#{CGI.escape client.system_token}"
      if response.success?
        JSON.parse(response.body).map do |site|
          User.new(site["id"], client, site["display_name"])
        end
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Push a user profile to this domain
    #
    # profile - [Hash] Hash of user data to publish per the Livefyre profile schema
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def add_user(profile)
      raise "Invalid ID" if profile["id"].nil?
      response = client.post "/profiles/?actor_token=#{CGI.escape client.system_token}&id=#{CGI.escape profile["id"]}", profile
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Create a new site on this domain
    #
    # Returns [Site] A new {Site site}.
    # Raises [APIException] when response is not valid
    def create_site(url)
      response = client.post "/sites/?actor_token=#{CGI.escape client.system_token}&url=#{CGI.escape url}"
      if response.success?
        opts = JSON.parse response.body
        Site.new(opts["id"], client, opts)
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Retrieve a list of owners associated with this domain
    #
    # Returns [Array<User>] An array of {User users}
    # Raises [APIException] when response is not valid
    def owners
      response = client.get "/owners/", {:actor_token => client.system_token}
      if response.success?
        JSON.parse(response.body).map do |u|
          client.user u.split("@", 2).first
        end
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Adds a user to the list of owners for this domain
    #
    # user - [String, User, Integer] User or user ID to add as an owner
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def add_owner(user)
      user = User.get_user(user, client)
      response = client.put "/owners/?actor_token=#{CGI.escape user.token}"
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Removes a user from the list of owners for this domain
    #
    # user - [String, User, Integer] User or user ID to remove as an owner
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def remove_owner(user)
      user = User.get_user(user, client)
      response = client.delete "/owners/?actor_token=#{CGI.escape user.token}"
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Retrieve a list of owners associated with this domain
    #
    # Returns [Array<User>] An array of {User users}
    # Raises [APIException] when response is not valid
    def admins
      response = client.get "/admins/", {:actor_token => client.system_token}
      if response.success?
        JSON.parse(response.body).map do |u|
          client.user u.split("@", 2).first
        end
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Adds a user to the list of owners for this domain
    #
    # user - [String, User, Integer] User or user ID to add as an admin
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def add_admin(user)
      user = User.get_user(user, client)
      response = client.post "/admins/?actor_token=#{CGI.escape user.token}", {:jid => user.jid}
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Removes a user from the list of owners for this domain
    #
    # user - [String, User, Integer] User or user ID to remove as an admin
    #
    # Returns [Bool] true on success
    # Raises [APIException] when response is not valid
    def remove_admin(user)
      user = User.get_user(user, client)
      response = client.delete "/admin/#{user.jid}/?actor_token=#{CGI.escape client.system_token}"
      if response.success?
        true
      else
        raise APIException.new(response.body)
      end
    end

    # Public: Sets the profile pull URL for the entire network.
    #
    # url - A URL template that includes the string "{{id}}" in it somewhere
    #
    # Returns [Bool] true on success
    # Raises APIException if the request failed
    def set_pull_url(url)
      result = client.post "/", {:pull_profile_url => url, :actor_token => client.system_token}
      if result.success?
        return true
      else
        raise APIException.new(result.body)
      end
    end

    # Internal: Returns a cleaner string representation of this object
    #
    # Returns [String] representation of this class
    def to_s
      "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(14, "0")} host='#{client.host}'>"
    end
  end
end