ENV["RAILS_ENV"] = "test"
require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'test_help'

if defined?(Ardes::TeslyReporter)
  Ardes::TeslyReporter.plugin_name = File.basename(File.expand_path(File.join(__FILE__, '../..')))
end

class Test::Unit::TestCase # :nodoc:
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
end