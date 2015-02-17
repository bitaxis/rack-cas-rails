require File.expand_path('../boot', __FILE__)

require 'rails/all'

##
# Need to require this so we can configure it in the Application class.

require "rack-cas"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    ##
    # Set the root URL of the CAS server (e.g. CASinoApp) in such a way that the entire application
    # (including the login_url method/helper) can get access to it via Rails.application.cas_server_url

    @cas_server_url = "https://cumulus.local:3334/"

    ##
    # Configure rack-cas to know about the CAS server root URL so that it knows where to
    # re-direct browser to for authentication

    config.rack_cas.server_url = @cas_server_url
  end
end

