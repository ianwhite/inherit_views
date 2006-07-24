require 'ardes/inherit_views'
ActionController::Base.class_eval { extend Ardes::ActionController::InheritViews }
ActionView::Base.class_eval { include Ardes::ActionView::InheritViews }