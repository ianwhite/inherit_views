module InheritViews
  module ActionController
    def self.included(base)
      base.class_eval do
        def self.view_paths=(paths)
          @view_paths = ::ActionView::Base.process_view_paths(paths, inherit_view_paths) if paths
        end
        
        def view_paths=(paths)
          @template.view_paths = ::ActionView::Base.process_view_paths(paths, inherit_view_paths)
        end
        
        extend ClassMethods
        
        delegate :inherit_views?, :inherit_view_paths, :to => 'self.class'
      end
    end
    
    module ClassMethods
      # Specify this to have your controller inherit its views from the specified path
      # or the current controller's default path if no argument is given
      def inherit_views(*paths)
        self.inherit_views = true
        self.inherit_view_paths = paths if paths.size > 0
      end
      
      # Return true if the controller is inheriting views
      def inherit_views?
        read_inheritable_attribute('inherit_views') ? true : false
      end
      
      # Instruct the controller that it is, or is not, inheriting views
      def inherit_views=(bool)
        write_inheritable_attribute('inherit_views', bool ? true : false)
      end
      
      # Return the inherit view paths, in order of self to ancestor
      #
      # Takes inherit_view_paths from the superclass when first read, and prepends the current controller_path.
      # An empty array is returned unless inherit_views?
      def inherit_view_paths
        if inherit_views?
          instance_variable_get('@inherit_view_paths') || instance_variable_set('@inherit_view_paths', [controller_path] + superclass.inherit_view_paths)
        else
          []
        end
      end

      # Set the inherit view paths, in order of self to ancestor.
      #
      # The controller_path for self is always prepended to the front, no matter what the arguments.
      def inherit_view_paths=(new_paths)
        new_paths -= [controller_path]
        old_paths = inherit_view_paths - [controller_path] - new_paths
        instance_variable_set('@inherit_view_paths', [controller_path] + new_paths + old_paths)
      end
    end
  end
  
  module ActionView
    def self.included(base)
      base.class_eval do
        def self.process_view_paths(value, inherit_view_paths = nil)
          returning InheritViews::PathSet.new(Array(value)) do |paths|
            paths.inherit_view_paths = inherit_view_paths if inherit_view_paths
          end
        end
        
        def view_paths=(paths)
          @view_paths = self.class.process_view_paths(paths, controller && controller.class.try(:inherit_view_paths))
        end
      end
    end
  end
  
  class PathSet < ::ActionView::PathSet
    attr_accessor :inherit_view_paths
  end
end