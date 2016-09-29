# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# https://github.com/rails/rails-controller-testing
# Even with the rails-controller-testing gem installed, we need these two lines to enable it
require 'rails-controller-testing'
Rails::Controller::Testing.install

# Need to use .env to shim in the CAS server URL so that I don't have to hard-code it into the source code and expose my
# private URL.  This means I need to have a .env file at the root directory of the gem.  I got this from
# https://github.com/bkeepers/dotenv#sinatra-or-plain-ol-ruby
require "dotenv"
Dotenv.load

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../dummy/test/fixtures", __FILE__)
end
