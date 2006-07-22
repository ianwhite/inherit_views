module Ardes# :nodoc:
  module ActionController# :nodoc:
    module InheritViews
      
      class PathNotFound < RuntimeError; end

      def self.included(base)
        base.class_eval do
          class_inheritable_accessor :inherit_view_paths, :exclude_default_path
          self.inherit_view_paths    = []
          self.exclude_default_path  = false
          extend ClassMethods
        end
      end
      
      module ClassMethods
        # specify this to have your controller inherit its views from the specified path
        # or the current controller's default path if no argument is given
        def inherit_views(*controllers)
          self.class_eval { include InstanceMethods }
          
          controllers = [self.controller_name] if controllers.size == 0
          controllers = controllers.collect {|c| c.to_s}
          
          self.inherit_view_paths -= controllers
          self.inherit_view_paths = controllers + self.inherit_view_paths
        end
        
        module InstanceMethods
          def self.included(base)
            base.hide_action self.public_instance_methods
          end
          
          def exclude_views_for(*paths, &block)
            paths = paths.collect {|p| sanitize_inherit_view_path(p)}
            protect_inherit_views_state do
              self.inherit_view_paths -= paths
              self.exclude_default_path = paths.include?(self.controller_name)
              yield
            end
          end

          def parent_views_for(path, &block)
            path = sanitize_inherit_view_path(path)
            protect_inherit_views_state do
              self.exclude_default_path = true
              if path_index = self.inherit_view_paths.index(path)
                self.inherit_view_paths.slice!(0..path_index)
              end
              yield
            end
          end
          
          def valid_inherit_views_path?(path)
            path == self.controller_name or self.inherit_view_paths.include?(path)
          end
        
        private
          def sanitize_inherit_view_path(path)
            unless valid_inherit_views_path?(path = path.to_s)
              raise PathNotFound, "'#{path}' is neither default: '#{self.controller_name}', nor found in '#{self.inherit_view_paths.join(', ')}'" 
            end
            path
          end

          def protect_inherit_views_state(&block)
            original_state = [self.inherit_view_paths.dup, self.exclude_default_path]
            yield
          ensure
            (self.inherit_view_paths, self.exclude_default_path) = original_state
          end
        end
      end
    end
  end
  
  module ActionView
    module InheritViews
      def self.included(base)
        base.alias_method_chain :full_template_path, :inherit_views
      end

    private
      def full_template_path_with_inherit_views(template_path, extension)
        full_path = full_template_path_without_inherit_views(template_path, extension)

        return full_path if File.exist?(full_path) unless controller.exclude_default_path

        # try and find the template in the inherited view paths views array
        controller.inherit_view_paths.each do |path|
          # try substiting the path (dirname of template_path) with path
          inh_full_path = full_template_path_without_inherit_views(template_path.sub(/^.*\//, path + '/'), extension)
          return inh_full_path if File.exist?(inh_full_path)

          # try prepending path to template_path (for views in a subfolder of another view folder)
          inh_full_path = full_template_path_without_inherit_views("#{path}/#{template_path}", extension)
          return inh_full_path if File.exist?(inh_full_path)
        end

        raise ::ActionView::ActionViewError, "No template found for #{template_path} in '#{controller.inherit_view_paths.join("', '")}' (and excluding default path '#{controller.controller_name}')" if controller.exclude_default_path

        # If it cannot be found in additional paths, return the default path
        return full_path
      end
    end
  end
end