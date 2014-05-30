$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mastiff/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mastiff"
    s.license     = "MIT"
    s.version     = Mastiff::VERSION
    s.authors     = ["Ashley Raiteri"]
    s.email       = ["ashley@raiteri.net"]
    s.homepage    = "https://github.com/ashrocket/mastiff.git"
    s.summary     = "Mastiff gem is a rails engine for processing and emailed artifacts that are regularly updated."
    s.description = <<eos
    Mastiff gem provides interface to an redis based model with Emails and attachments.
eos


  s.files         = `git ls-files`.split("\n") + ['lib/generators/air_oag/install_generator.rb']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_path  = "app/api"

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency 'coffee-rails', '~> 4.0'
  s.add_dependency 'jquery-rails', '~> 3.1'
  s.add_dependency 'sass-rails', '~> 4.0'
  s.add_dependency 'bootstrap-sass', '~> 3.1'
  s.add_dependency 'jquery-datatables-rails', '~> 1.12'

  s.add_dependency 'mail', '~> 2.5'
  s.add_dependency 'carrierwave', '~> 0.10'
  s.add_dependency 'aws-s3', '~> 0.6'
  s.add_dependency 'redis-objects', '~> 0.9'



  #s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

end
