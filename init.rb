require 'inherit_views'

ActionController::Base.send :extend, InheritViews::ClassMethods
ActionView::Base.send :include, InheritViews::ActionView