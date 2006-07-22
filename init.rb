require 'ardes/view_mapping'
ActionController::Base.class_eval { include Ardes::ActionController::ViewMapping }
ActionView::Base.class_eval { include Ardes::ActionView::ViewMapping }

require 'ardes/inherit_views'
ActionController::Base.class_eval { include Ardes::ActionController::InheritViews }
ActionView::Base.class_eval { include Ardes::ActionView::InheritViews }
