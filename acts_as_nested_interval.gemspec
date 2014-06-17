$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_nested_interval/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_nested_interval"
  s.version     = ActsAsNestedInterval::VERSION
  s.authors     = ["Nicolae Claudius", "Pythonic", "Grzegorz Łuszczek"]
  s.email       = ["grzegorz@piklus.pl"]
  s.homepage    = "https://github.com/grzlus/acts_as_nested_interval"
  s.summary     = "Encode Trees in RDBMS using nested interval method."
  s.description = "Encode Trees in RDBMS using nested interval method for powerful querying and speedy inserts."

  s.required_ruby_version = '>= 2.0'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", ">= 4.0"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "database_cleaner"

  s.post_install_message = <<-END
 New version of acts_as_nested_interval has a lot of changes (could crash your app!):

 * Refactored code
 * Added cache for depth
 * Simpler queries
 * Droped support for rails 1.9 and 1.8 (Keywords arguments, Refinements)
 * Added more configure option
  END
end
