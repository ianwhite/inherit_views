module InheritViews
  module ActionController
    def self.included(base)
      base.class_eval do
        def self.view_paths=(paths)
          @view_paths = ActionView::Base.process_view_paths(value, self) if value
        end
        
        def view_paths=(value)
          @template.view_paths = ActionView::Base.process_view_paths(value, self.class)
        end
        
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def inherit_views(*args)
      end
    end
  end
  
  module ActionView
    def self.included(base)
      base.class_eval do
        def self.process_view_paths(value, controller_class = nil)
          returning InheritViews::PathSet.new(Array(value)) do |paths|
            paths.controller_class = controller_class
          end
        end
        
        def view_paths=(paths)
          @view_paths = self.class.process_view_paths(paths, controller.class)
        end
      end
    end
  end
  
  class PathSet < ::ActionView::PathSet
    attr_accessor :controller_class
  end
end