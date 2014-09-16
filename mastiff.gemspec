#$:.push File.expand_path("../lib", __FILE__)

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

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


    #s.files         = `git ls-files`.split("\n")
    s.files = Dir.glob("{bin,lib}/**/*") + %w(README.md)

    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

    s.require_paths = ["lib"]

    s.add_dependency "rails", "~> 4.0"

    s.add_dependency 'mail', '~> 2.6'
    s.add_dependency 'carrierwave', '~> 0.10'
    s.add_dependency 'aws-s3', '~> 0.6'
    s.add_dependency 'redis-objects', '~> 0.9'
    s.add_dependency 'highline'

  s.add_dependency 'sidekiq',  '~> 2.17.7'
  s.add_dependency 'sidetiq',  '~> 0.5'
  s.add_dependency 'sidekiq-lock',  '~> 0.2'



  #s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.description = <<eos
  Mastiff gem provides interface to an redis based model with Emails and attachments.
eos

end
