module Livefyre
  class Railtie < Rails::Railtie
    initializer "livefyre.initializer" do
      ActionController::Base.send :include, Livefyre::Controller
      ActionView::Base.send :include, Livefyre::Helpers
      ActiveRecord::Base.send :include, Livefyre::Model if defined?(ActiveRecord)
    end
  end
end