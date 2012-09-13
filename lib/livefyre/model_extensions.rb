module Livefyre
  module Model
    extend ActiveSupport::Concern

    # Resque worker for updating Livefyre users via ping-to-pull
    class RequestPull
      @queue = :livefyre

      # Public: Pings Livefyre, requesting that the user identified by the passed ID is refreshed.
      def self.perform(id)
        Livefyre::User.new( id ).refresh
      end
    end

    # Public: Ping Livefyre to refresh this user's record
    #
    # defer - If true, will use Resque to process the update
    def refresh_livefyre(defer = false)
      livefyre_id = self._livefyre_id
      if defer
        if defined?(Resque)
          Resque.enqueue Livefyre::Model::RequestPull, livefyre_id
        else
          raise ":defer was passed, but Resque was not found"
        end
      else
        Livefyre::Model::RequestPull.perform livefyre_id
      end
    end

    protected

    def update_livefyre_if_fields_changed
      if updates = _livefyre_options[:update_on]
        updates.each do |field|
          if send("#{field}_changed?")
            refresh_livefyre _livefyre_options[:defer]
            break
          end
        end
      end
    end

    def _livefyre_options
      self.class.instance_variable_get("@livefyre_options")
    end

    def _livefyre_id
      livefyre_id = self.id
      if _livefyre_options[:id]
        livefyre_id = self.send(_livefyre_options[:id])
      end
      livefyre_id
    end

    public

    module ClassMethods
      # Public: Adds callback handlers and additional methods for treating this record as a user record.
      #
      # options    - [Hash] of options to initialize behavior with
      # :update_on - [Array<Symbol>] List of fields which should trigger a Livefyre update when they're updated.
      # :id        - [Symbol] Name of the method to use for determining this record's livefyre ID. If not given, #id is used.
      #
      # Examples
      #
      #    livefyre_user :update_on => [:email, :first_name, :last_name, :username, :picture_url], :id => :custom_livefyre_id
      #
      # Returns [nil]
      def livefyre_user(options = {})
        @livefyre_options = options
        after_save :update_livefyre_if_fields_changed
      end
    end
  end
end