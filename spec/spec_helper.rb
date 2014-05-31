# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'byebug'
require 'air_oag'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.join(File.dirname(__FILE__))
end

Rails.backtrace_cleaner.remove_silencers!
# Load support files

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include Helpers

end

def fixture(*name)
  File.join(SPEC_ROOT, 'fixtures', name)
end

alias doing lambda





