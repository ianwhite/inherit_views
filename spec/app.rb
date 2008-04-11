class InheritViewsTestController < ActionController::Base
  self.view_paths = [File.dirname(__FILE__) + '/fixtures/views']
end

# :a controller is a normal controller with inherit_views
# its subclasses will inherit its views
class AController < InheritViewsTestController
  inherit_views

  def in_a; end
  def in_ab; end
  def in_abc; end
  def render_parent; end
  def inherited_template_path; end
end

# :b controller is a normal controller with inherit_views 'a'
# It will inherit a's views, and its sublcasses will inherit its views ('b', then 'a')
class BController < InheritViewsTestController
  inherit_views 'a'

  def in_a; end
  def in_ab; end
  def in_b; end
  def in_abc; end
  def render_parent; end
  def bad_render_parent; end
  def partial_in_bc; end
  def partial_in_b; end
end

# :c cotroller is a subclass of :b controller, so it inheirt's b's views ('c', 'b', then 'a')
class CController < BController

  def in_c; end
  def render_parent; end
end

# :d controller is a subclass of :a controller, with inherit_views 'other', so its views == ('d', 'other', then 'a')
class DController < AController
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