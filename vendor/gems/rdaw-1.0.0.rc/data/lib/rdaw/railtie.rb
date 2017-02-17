if Object.const_defined?('Rails') && Rails.const_defined?('Railtie')
  require 'rdaw_middleware'
  
  class RdawRailtie < Rails::Railtie
    initializer "rdaw_railtie.configure_rails_initialization" do |app|
      app.middleware.use RdawMiddleware
    end
  end
end