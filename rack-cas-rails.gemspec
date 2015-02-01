Gem::Specification.new do |spec|

  spec.name        = "rack-cas-rails"
  spec.version     = "0.0.1"
  spec.date        = "2015-02-01"
  spec.summary     = "Enables Rails application to use CASinoApp for authentication."
  spec.description = "Provides integration glue between a Rails application and biola/rack-cas so that a Rails application can use CASinoApp for authentication."
  spec.authors     = ["Nathan Brazil"]
  spec.email       = 'nb@bitaxis.com'
  spec.files       = [
    "lib/rack-cas/rails/controllers.rb",
    "lib/rack-cas/rails/helpers.rb",
    "lib/rack-cas/rails.rb",
    "LICENSE",
    "README.md"
    ]
  spec.homepage    = "https://github.com/bitaxis/json_hash.git"
  spec.license     = "MIT"

  spec.add_runtime_dependency "rack-cas", "~> 0.9.2"
  spec.add_runtime_dependency "rails",    "~> 4.2", ">= 4.2.0"

end
