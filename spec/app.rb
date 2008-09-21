class InheritViewsTestController < ActionController::Base
  self.view_paths = [File.dirname(__FILE__) + '/fixtures/views']
end

# :a controller is a normal controller with inherit_views
# its subclasses will inherit its views
class AController < InheritViewsTestController
  inherit_views
end

# :b controller is a normal controller with inherit_views 'a'
# It will inherit a's views, and its sublcasses will inherit its views ('b', then 'a')
class BController < InheritViewsTestController
  inherit_views 'a'
end

# :c cotroller is a subclass of :b controller, so it inheirt's b's views ('c', 'b', then 'a')
class CController < BController
end

# :d controller is a subclass of :a controller, with inherit_views 'other', so its views == ('d', 'other', then 'a')
class DController < AController
  inherit_views 'other'
end

# used to test that inherit_views doesn't muck anything else up
class NormalController < InheritViewsTestController
end
