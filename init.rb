require 'inherit_views'

ActionController::Base.send :extend, InheritViews::ActionController
ActionView::Base.send :include, InheritViews::ActionView