require 'ardes/inherit_views'

if defined?(ActionMailer)
  ActionMailer::Base.send :extend, Ardes::InheritViews::ActionController
end
ActionController::Base.send :extend, Ardes::InheritViews::ActionController
ActionView::Base.send :include, Ardes::InheritViews::ActionView