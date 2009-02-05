require 'inherit_views'

ActionController::Base.send :include, InheritViews::ActionController
ActionView::Base.send :include, InheritViews::ActionView