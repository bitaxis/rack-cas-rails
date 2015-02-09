module RackCas::Rails
  if defined?(Rails)
    require "rack-cas-rails/controllers.rb"
    require "rack-cas-rails/helpers.rb"
  end
end
