module Livefyre
  class Railtie < Rails::Railtie
    initializer "livefyre.initializer" do
      ActionController::Base.send :include, Livefyre::Controller
      ActionView::Base.send :include, Livefyre::Helpers
    end
  end
end