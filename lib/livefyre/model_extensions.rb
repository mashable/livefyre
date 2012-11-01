module Livefyre
  module Model
    extend ActiveSupport::Concern

    # Public: Ping Livefyre to refresh this user's record
    def refresh_livefyre
      if _livefyre_callback
        _livefyre_callback.call(self, self._livefyre_id)
      else
        Livefyre::User.refresh( self._livefyre_id )
      end
    end

    protected

    def update_livefyre_if_fields_changed
      if updates = _livefyre_options[:update_on]
        updates.each do |field|
          if send("#{field}_changed?")
            refresh_livefyre
            break
          end
        end
      end
    end

    def _livefyre_options
      self.class.instance_variable_get("@livefyre_options")
    end

    def _livefyre_callback
      self.class.instance_variable_get("@livefyre_update_block")
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
      def livefyre_user(options = {}, &block)
        @livefyre_options = options
        @livefyre_update_block = block
        after_save :update_livefyre_if_fields_changed
      end
    end
  end
end