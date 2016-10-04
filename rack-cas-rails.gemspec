$:.push File.expand_path("../lib", __FILE__)

require "rack-cas-rails/version"

Gem::Specification.new do |spec|

  spec.name        = "rack-cas-rails"
  spec.version     = RackCASRails::VERSION
  spec.date        = "2016-09-29"
  spec.summary     = "Enables a Rails application to use CAS-compliant server for authentication."
  spec.description = "Provides the integration glue between a Rails application and biola/rack-cas so that a CAS-compliant server (only tested with CASinoApp) can be used for authentication by the application."
  spec.authors     = ["Nathan Brazil"]
  spec.email       = 'nb@bitaxis.com'
  spec.files       = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE",
    "README.md"
    ]
  spec.homepage    = "https://github.com/bitaxis/rack-cas-rails.git"
  spec.license     = "MIT"

  spec.add_runtime_dependency "byebug", "~> 9.0"
  spec.add_runtime_dependency "rack-cas", "~> 0.15"
  spec.add_runtime_dependency "rails",    "~> 5.0", ">= 5.0.0"

  spec.add_development_dependency "byebug", "~> 9.0"
  spec.add_development_dependency "dotenv-rails", "~> 1.0"
  spec.add_development_dependency "rails-controller-testing", "~> 1.0"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "yard", "~> 0.8"

end
