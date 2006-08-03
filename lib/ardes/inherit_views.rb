module Ardes# :nodoc:
  module ActionController# :nodoc:
    #
    # Specify this in your controller to have its views inherite parent controller's views
    # You can also use a _parent_view_ method in templates which allows view and partials
    # to work like inherited methods (and 'super')
    #
    # Example of controller
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
    # == In Controllers
    #
    # In the example above, If BarController, or any of the views in views/bar, renders 'bar/view'
    # and it is not found then 'foo/view' is rendered (if it can be found)
    #
    # You can also specify an inherit path other than the default (it does not have to be the default controller path)
    # If your controller inherits from a controller with inherit_views then that controller
    # gets the inherited view paths as well.
    #
    #   class FooController < ApplciationController
    #     inherit_views 'far', 'faz'   # will look for views in 'foo', then 'far', then 'faz'
    #   end
    #
    #   class BarController < FooController 
    #     # will look for views in 'bar', 'far', 'faz'
    #   end
    #
    # If you want to turn off inherited views for a controller that has inherit_views in its
    # ancestors use has_inherited_views=
    #
    #   class BarController < FooController
    #     self.has_inherited_views = false
    #   end
    #
    # You can specify inherited views for a module that is mixed in to ActionController
    # by specifying the view path(s)
    #
    #   module BarMixin
    #     inherit_views 'bar'
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
    # == In Views
    #
    module InheritViews
      
      # Raised when a matching template_path cannot be found amongst the default view path
      # or inherited view paths
      class PathNotFound < RuntimeError; end

      def self.extended(base)# :nodoc:
        base.class_eval { class_inheritable_accessor :has_inheritable_views }
      end
      
      # Specify this to have your controller inherit its views from the specified path
      # or the current controller's default path if no argument is given
      def inherit_views(*view_paths)
        unless self.included_modules.include?(Ardes::ActionController::InheritViews::InstanceMethods)
          class_inheritable_accessor :inherit_view_paths
          self.inherit_view_paths = []
          include InstanceMethods
        end
        
        self.has_inheritable_views = true
        
        view_paths = [self.controller_path] if view_paths.size == 0
        view_paths = view_paths.collect {|p| p.to_s }
        self.inherit_view_paths = self.inherit_view_paths - view_paths
        self.inherit_view_paths = view_paths + self.inherit_view_paths
      end
      
      module InstanceMethods
        def self.included(base)# :nodoc:
          base.hide_action self.public_instance_methods
          base.class_eval do
            alias_method_chain :render_file, :inherit_views
            alias_method_chain :default_template_name, :inherit_views
          end
        end
        
        # picks an inherited view prior to rendering
        def render_file_with_inherit_views(template_path, status = nil, use_full_path = false, locals = {}) #:nodoc:
          template_path = pick_template_path(template_path) if self.has_inheritable_views and use_full_path
          render_file_without_inherit_views(template_path, status, use_full_path, locals)
        end
        
        # Picks the first template that exists in the inherited view paths (including the default path)
        # Use this before rendering
        def pick_template_path(template_path)
          @template.file_exists?(template_path) ? template_path : pick_inherited_template_path(template_path)
        end
        
        # Picks the first tmeplate that exists from the given path array (which defaults to
        # the controllers inherit_veiw_paths array)
        def pick_inherited_template_path(template_path, from = self.inherit_view_paths)
          from.each do |path|
            inh_path = template_path.sub(/^.*?\//, path + '/')
            return inh_path if @template.file_exists?(inh_path) 
          end
          raise PathNotFound, "No template found for #{template_path} in '#{from.join("', '")}'"
        end
      
      private
        # picks template path on the default template name
        def default_template_name_with_inherit_views(action_name = self.action_name)
          pick_template_path(default_template_name_without_inherit_views(action_name))
        end
      end
    end
  end
  
  module ActionView# :nodoc:
    #
    # Modifications to ActionView required by inherit_views
    #
    # There is a new method render_parent, which renders first view that can
    # be found higher in the inherited view paths with the same name as the current
    # view being rendered
    #
    #   <%= render_parent %>
    #   <%= render_parent :locals => {:foo => foo} %>
    #   <%= render_parent :layout => false %>
    #
    # To enable this functionality, there is a new instance variable _@current_render_
    # which holds the name of the file currently being rendered (similar to @first_render).
    # In tempate 'views/foo/bar.rhtml'
    #
    #   <%= @current_render %>
    #
    # will produce 'foo/bar.rhtml'
    #
    # Calls to render will function as normal within templates, as well as searching for
    # inherited views when a template can't be found
    #
    module InheritViews
      def self.included(base)# :nodoc:
        base.class_eval do
          alias_method_chain :render_file, :inherit_views
        end
      end
      
      # Renders the parent template for the current template
      # takes normal rendering options (:layout, :locals, etc)
      def render_parent(options = {})
        current_path = @current_render.sub(/\/.*$/, '')
        
        inherit_paths = controller.inherit_view_paths.dup
        if path_index = inherit_paths.index(current_path)
          inherit_paths.slice!(0..path_index)
        end
        
        to_render = controller.pick_inherited_template_path(@current_render, inherit_paths)
        
        render(options.merge(:file => to_render, :use_full_path => true))
      end
      
      # Picks an inherited template path prior to rendering, and also sets @current_render for
      # the template being rendered
      def render_file_with_inherit_views(template_path, use_full_path = true, local_assigns = {})# :nodoc:
        orig_current_render = @current_render
        
        template_path = controller.pick_template_path(template_path) if controller.has_inheritable_views and use_full_path
        
        @current_render = template_path
        render_file_without_inherit_views(template_path, use_full_path, local_assigns)
      
      ensure
        @current_render = orig_current_render
      end
    end
  end
end