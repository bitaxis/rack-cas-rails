$:.push File.expand_path("../lib", __FILE__)

require "rack-cas-rails/version"

Gem::Specification.new do |spec|

  spec.name        = "rack-cas-rails"
  spec.version     = RackCASRails::VERSION
  spec.date        = "2015-02-09"
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

  spec.add_runtime_dependency "rack-cas", "~> 0.9.2"
  spec.add_runtime_dependency "rails",    "~> 4.2", ">= 4.2.0"

end
