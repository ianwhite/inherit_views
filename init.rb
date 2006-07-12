require 'ardes/action_view'
require 'ardes/inherit_views'
ActionController::Base.class_eval { include Ardes::ActionController::InheritViews }
