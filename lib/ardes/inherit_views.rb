module Ardes#:nodoc:
  # Allow your controllers to inherit their views from parent controllers, or from
  # specified view paths.
  #
  # === Example
  #  
  #   class FooController < ApplicationController
  #     inherit_views
  #   end
  #
  #   class BarController < FooController
  #     ... # will look for views in 'views/bar' and 'views/foo' 
  #   end
  #
  # in views/foo/_my_view.rhtml:
  #
  #   <h1>My View Thing</h1>
  #
  # in views/bar/_my_view.rhtml:
  #
  #   <%= render_parent %>
  #   <p>With some bar action</p>
  # 
  # === In Controllers
  #
  # In the example above, If BarController, or any of the views in views/bar, renders 'bar/view'
  # and it is not found then 'foo/view' is rendered (if it can be found)
  #
  # You can also specify an inherit path other than the default (it does not have to be the default controller path)
  # If your controller inherits from a controller with inherit_views then that controller
  # gets the inherited view paths as well.
  #
  #   class FooController < ApplicationController
  #     inherit_views 'far', 'faz'   # will look for views in 'foo', then 'far', then 'faz'
  #   end
  #
  #   class BarController < FooController 
  #     # will look for views in 'bar', 'foo', 'far', 'faz'
  #   end
  #
  # If you want to turn off inherited views for a controller that has inherit_views in its
  # ancestors use self.inherit_views=
  #
  #   class BarController < FooController
  #     self.inherit_views = false
  #   end
  #
  # You can completely override the inherited view paths in a subclass controller using
  # inherit_view_paths=
  #
  #   class BarController < FooController
  #     self.inherit_view_paths = ['you_can_go', 'your_own_way']
  #     # will look for views in 'bar', 'you_can_go', and 'your_own_way'
  #     # (not 'far' or 'faz' from FooController)
  #   end
  #
  module InheritViews
    
    # raised when an inherited file cannot be found, and one is required (e.g. in render_parent)
    class InheritedFileNotFound < RuntimeError; end
    
    # extension for ActionController::Base which enables inherit_views, this module is extended into
    # ActionController::Base
    module ActionController
      # Specify this to have your controller inherit its views from the specified path
      # or the current controller's default path if no argument is given
      def inherit_views(*paths)
        class_eval do
          unless included_modules.include? ::Ardes::InheritViews::ActionController::InstanceMethods
            extend ClassMethods
            include InstanceMethods
            extend CachedInheritedTemplatePaths if ENV['RAILS_ENV'] == 'production'
          end
          self.inherit_views = true
          self.inherit_view_paths = paths if paths.size > 0
        end
      end

      # Return true if the controller is inheriting views
      def inherit_views?
        !!read_inheritable_attribute('inherit_views')
      end        
      
      module ClassMethods
        # Instruct the controller that it is not inheriting views
        def inherit_views=(bool)
          write_inheritable_attribute('inherit_views', !!bool)
        end
        
        # Return the inherit view paths, in order of self to ancestor
        #
        # Takes inherit_view_paths from the superclass when first read, and prepends the current controller_path
        def inherit_view_paths
          instance_variable_get('@inherit_view_paths') || instance_variable_set('@inherit_view_paths', [controller_path] + (superclass.inherit_view_paths rescue []))
        end

        # Set the inherit view paths, in order of self to ancestor.
        #
        # The controller_path for self is always prepended to the front, no matter what the arguments
        def inherit_view_paths=(paths)
          instance_variable_set('@inherit_view_paths', [controller_path] + (paths - [controller_path]))
        end
        
        def find_inherited_template_path_in(template, template_path, include_self = true)
          if inherit_path = inherit_view_paths.find {|p| template_path =~ /^#{p}\//}
            paths = inherit_view_paths.slice(inherit_view_paths.index(inherit_path) + (include_self ? 0 : 1)..-1)
            if found_path = paths.find {|p| template.file_exists?(template_path.sub(/^#{inherit_path}/, p))}
              return template_path.sub(/^#{inherit_path}/, found_path)
            end
          end
          nil
        end
      end
      
      module InstanceMethods
        def self.included(base)#:nodoc:
          base.send :hide_action, *public_instance_methods
          base.send :alias_method_chain, :render_file, :inherit_views
        end
        
        # Return true if the controller is inheriting views
        def inherit_views?
          self.class.inherit_views?
        end
        
        # Return the inherit view paths, in order of self to ancestor
        def inherit_view_paths
          self.class.inherit_view_paths
        end
        
        # intercepts render_file and looks for an inherited template_path, if appropriate
        def render_file_with_inherit_views(template_path, status = nil, use_full_path = false, locals = {})
          if use_full_path and inherit_views? and found_path = find_inherited_template_path(template_path)
            template_path = found_path
          end
          render_file_without_inherit_views(template_path, status, use_full_path, locals)
        end

        # given a template_path, returns the first existing template_path in parent inherit paths.
        # If +include_self+ is false, the search does not include the passed template_path
        #
        # If one cannot be found, then nil is returned
        def find_inherited_template_path(template_path, include_self = true)
          self.class.find_inherited_template_path_in(@template, template_path, include_self)
        end
      end
      
      # This module is included into inherit_views controllers in production mode.  It's purpose is
      # to cache the calls to find_inherited_template_path, so that the file system is not relentlessly
      # queried to find the inherited template_path.
      module CachedInheritedTemplatePaths
        def self.extended(base)#:nodoc:
          base.class_eval do
            class<<self
              alias_method_chain :find_inherited_template_path_in, :cache
            end
          end
        end
        
        def inherited_template_paths_cache
          instance_variable_get('@inherited_template_paths_cache') || instance_variable_set('@inherited_template_paths_cache', {})
        end
          
        def find_inherited_template_path_in_with_cache(template, template_path, include_self = true)
          inherited_template_paths_cache[[template_path, include_self]] ||= find_inherited_template_path_in_without_cache(template, template_path, include_self)
        end
      end
    end
    
    # Mixin for ActionView to enable inherit views functionality.  This module is
    # included into ActionView::Base
    #
    # +render_file+ is modified so that it picks an inherited file to render
    # 
    # +render_parent+ is introduced
    #
    # Those familiar with the internals of ActionView will know that the <tt>@first_render</tt>
    # instance var is used to keep track of what is the 'root' template being rendered.  A similar
    # variable <tt>@current_render</tt> is introduced to keep track of the filename of the currently rendered
    # file.  This enables +render_parent+ to know which to file render.
    #
    module ActionView
      def self.included(base)# :nodoc:
        base.send :alias_method_chain, :render_file, :inherit_views
      end

      # Renders the parent template for the current template
      # takes normal rendering options (:layout, :locals, etc)
      def render_parent(options = {})
        raise ArgumentError, 'render_parent requires that controller inherit_views' unless (controller.inherit_views? rescue false)
        if template_path = controller.find_inherited_template_path(@current_render, include_self = false)
          render(options.merge(:file => template_path, :use_full_path => true))
        else
          raise InheritedFileNotFound, "no parent for #{@current_render} found"
        end
      end

      # Find an inherited template path prior to rendering, if appropriate.  Also sets @current_render = to
      # the template currently being rendered
      def render_file_with_inherit_views(template_path, use_full_path = true, local_assigns = {})
        saved = @current_render
        if use_full_path and (controller.inherit_views? rescue false) and found_path = controller.find_inherited_template_path(template_path) 
          template_path = found_path
        end
        @current_render = template_path
        render_file_without_inherit_views(template_path, use_full_path, local_assigns)
      ensure
        @current_render = saved
      end
      
      # Find inherited template path for the given path, optionally pass a controller class 
      # to find the inherited view for the passed controller class
      def inherited_template_path(template_path, klass = controller.class)
        klass.find_inherited_template_path_in(self, template_path)
      end
    end
  end  
end