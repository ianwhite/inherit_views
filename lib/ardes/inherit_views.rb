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
          end
          self.inherit_views = true
          self.inherit_view_paths = paths if paths.size > 0
        end
      end
      
      module ClassMethods
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
        # Takes inherit_view_paths from the superclass when first read, and prepends the current controller_path
        def inherit_view_paths
          instance_variable_get('@inherit_view_paths') || instance_variable_set('@inherit_view_paths', [controller_path] + (superclass.inherit_view_paths rescue []))
        end

        # Set the inherit view paths, in order of self to ancestor.
        #
        # The controller_path for self is always prepended to the front, no matter what the arguments
        def inherit_view_paths=(paths)
          inherited = inherit_view_paths - paths - [controller_path]
          instance_variable_set('@inherit_view_paths', [controller_path] + ((paths - [controller_path]) + inherited))
        end
      end
      
      module InstanceMethods
        # Return true if the controller is inheriting views
        def inherit_views?
          self.class.inherit_views?
        end
        
        # Return the inherit view paths, in order of self to ancestor
        def inherit_view_paths
          self.class.inherit_view_paths
        end
      end
    end
    
    # Mixin for ActionView to enable inherit views functionality.  This module is
    # included into ActionView::Base
    #
    # Those familiar with the internals of ActionView will know that the <tt>@first_render</tt>
    # instance var is used to keep track of what is the 'root' template being rendered.  A similar
    # variable <tt>@current_render</tt> is introduced to keep track of the filename of the currently rendered
    # file.  This enables +render_parent+ to know which to file render.
    #
    module ActionView
      extend ActiveSupport::Memoizable
      
      def self.included(base)# :nodoc:
        base.class_eval do
          alias_method_chain :render, :inherit_views
          
          alias_method :_orig_pick_template, :_pick_template
          
          def _pick_template(template_path)
            _pick_inherited_template_for_controller(template_path, controller)
          end
        end
      end
      
      # Renders the parent template for the current template
      # takes normal rendering options (:layout, :locals, etc)
      def render_parent(options = {})
        raise ArgumentError, 'render_parent requires that controller inherit_views' unless (controller.inherit_views? rescue false)
        
        if @current_render && @current_render[:file] && (file = _pick_inherited_template(@current_render[:file], controller.inherit_view_paths))
          return render(options.merge(:file => file))
        end
        raise InheritedFileNotFound, "no parent for #{@current_render[:file]} found"
      end

      # Find an inherited template path prior to rendering, if appropriate.
      def render_with_inherit_views(options = {}, local_assigns = {}, &block)
        _with_current_render_of(options.slice(:file, :partial)) do
          render_without_inherit_views(options, local_assigns, &block)
        end
      end
    
      # Find an inherited template path for a controller context
      def inherited_template_path(template_path, controller_class = controller.class)
        _pick_inherited_template_for_controller(template_path, controller).to_s
      end
    
    private
      def _pick_inherited_template_for_controller(template_path, controller)
        _orig_pick_template(template_path)
      rescue ::ActionView::MissingTemplate
        if (controller.inherit_views? rescue false)
          _pick_inherited_template(template_path, controller.inherit_view_paths)
        end
      end  
      
      def _pick_inherited_template(template_path, inherit_view_paths)
        starting_path = inherit_view_paths.detect {|p| template_path =~ /^#{p}\//}
        
        if starting_path 
          inherit_paths_above_starting_path = inherit_view_paths.slice(inherit_view_paths.index(starting_path)+1..-1)
          
          inherit_paths_above_starting_path.each do |path|
            inherited_template = begin
              _orig_pick_template(template_path.sub(/^#{starting_path}/, path))
            rescue ::ActionView::MissingTemplate
              nil
            end
            
            return inherited_template if inherited_template
          end
        end
      end
      memoize :_pick_inherited_template
      
      def _with_current_render_of(options, &block)
        orig, @current_render = @current_render, options
        yield
      ensure
        @current_render = orig
      end
    end
  end  
end