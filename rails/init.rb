require File.dirname(__FILE__) + "/../inherit_views/inherit_views"

defined?(ActionController) && ActionController::Base.extend(InheritViews::ActMethod)
defined?(ActionMailer) && ActionMailer::Base.extend(InheritViews::ActMethod)
defined?(ActionView) && ActionView::Base.send(:include, InheritViews::ActionView)
