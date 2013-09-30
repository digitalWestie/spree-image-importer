$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spree-image-importer"
  s.version     = "1.0.0"
  s.authors     = ["Rory Gianni"]
  s.email       = ["hello@rorygianni.me.uk"]
  s.homepage    = "http://rorygianni.me.uk"
  s.summary     = "Helps import picture en masse"
  #s.description = "optional"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  #s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_development_dependency "sqlite3"
end