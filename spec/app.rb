# TODO: specs could be better: write better examples, with descriptive names 
# rather than 'first', 'second' etc...
class TestController < ActionController::Base
  self.view_paths = [File.dirname(__FILE__) + '/fixtures/views']
  
  # we're pretending that these controllers are not modulized
  def self.controller_path
    controller_name
  end
end

class FirstController < TestController
  inherit_views

  def in_first; end
  def in_first_and_second; end
  def in_all; end
  def render_parent; end
end

class SecondController < TestController
  inherit_views 'first'

  def in_first; end
  def in_first_and_second; end
  def in_second; end
  def in_all; end
  def render_parent; end
end

class ThirdController < SecondController

  def in_third; end
  def render_parent; end
end

# These are created in production mode to test caching
ENV["RAILS_ENV"] = 'production'

class ProductionModeController < TestController
  inherit_views
end

class OtherProductionModeController < ProductionModeController
end

# back to test mode
ENV['RAILS_ENV'] = 'test'