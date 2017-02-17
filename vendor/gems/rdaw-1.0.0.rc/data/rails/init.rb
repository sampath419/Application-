require 'rdaw.rb'

if ActionController.const_defined?('Dispatcher')
  require 'rdaw_middleware.rb'
  ActionController::Dispatcher.middleware.use 'RdawMiddleware'
end
