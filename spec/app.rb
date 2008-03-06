# TODO: specs could be better: write better examples, with descriptive names 
# rather than 'first', 'second' etc...
class InheritViewsTestController < ActionController::Base
  self.view_paths = [File.dirname(__FILE__) + '/fixtures/views']
end

class FirstController < InheritViewsTestController
  inherit_views

  def in_first; end
  def in_first_and_second; end
  def in_all; end
  def render_parent; end
  def inherited_template_path; end
end

class SecondController < InheritViewsTestController
  inherit_views 'first'

  def in_first; end
  def in_first_and_second; end
  def in_second; end
  def in_all; end
  def render_parent; end
  def bad_render_parent; end
  def partial; end
  def partial2; end
end

class ThirdController < SecondController

  def in_third; end
  def render_parent; end
end

class FourthController < FirstController
  inherit_views 'other'
end

# These are created in production mode to test caching
ENV["RAILS_ENV"] = 'production'

class ProductionModeController < InheritViewsTestController
  inherit_views
end

class OtherProductionModeController < ProductionModeController
end

# back to test mode
ENV['RAILS_ENV'] = 'test'