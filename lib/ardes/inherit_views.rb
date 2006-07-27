module Ardes# :nodoc:
  module ActionController# :nodoc:
    module InheritViews
      
      class PathNotFound < RuntimeError; end

      def self.extended(base)
        base.class_eval { class_inheritable_accessor :has_inheritable_views }
      end
      
      # specify this to have your controller inherit its views from the specified path
      # or the current controller's default path if no argument is given
      def inherit_views(*view_paths)
        unless self.included_modules.include?(Ardes::ActionController::InheritViews::InstanceMethods)
          class_inheritable_accessor :inherit_view_paths, :inherit_view_paths_cache
          self.inherit_view_paths             = []
          include InstanceMethods
        end
        
        self.has_inheritable_views = true
        
        view_paths = [self.controller_path] if view_paths.size == 0
        view_paths = view_paths.collect {|p| p.to_s }
        self.inherit_view_paths = self.inherit_view_paths - view_paths
        self.inherit_view_paths = view_paths + self.inherit_view_paths
        
        self.inherit_view_paths_cache = {}
        self.inherit_view_paths_cache[self.controller_path] = {}
        self.inherit_view_paths.each {|scope| self.inherit_view_paths_cache[scope] = {}}
      end
      
      module InstanceMethods
        def self.included(base)
          base.hide_action self.public_instance_methods
          base.class_eval do
            alias_method_chain :render_file, :inherit_views
            alias_method_chain :default_template_name, :inherit_views
          end
        end

        def parent_views_for(path, &block)
          unless valid_inherit_views_path?(path = path.to_s)
            raise PathNotFound, "'#{path}' is neither default: '#{self.class.controller_path}', nor found in '#{self.inherit_view_paths.join(', ')}'" 
          end
            
          original_state = [self.inherit_view_paths.dup, @inherit_views_exclude_default]
            
          @inherit_views_exclude_default = true
          if path_index = self.inherit_view_paths.index(path)
            self.inherit_view_paths.slice!(0..path_index)
          end
          yield
          
        ensure
          (self.inherit_view_paths, @inherit_views_exclude_default) = original_state
        end
          
        def valid_inherit_views_path?(path)
          path == self.class.controller_path or self.inherit_view_paths.include?(path)
        end
        
        def render_file_with_inherit_views(template_path, status = nil, use_full_path = false, locals = {}) #:nodoc:
          template_path = pick_inherited_template_path(template_path) if self.has_inheritable_views and use_full_path
          render_file_without_inherit_views(template_path, status, use_full_path, locals)
        end
        
        # given a template path and extension,
        def pick_inherited_template_path(template_path)
          if cached = inherit_views_get_cached(template_path)
            return cached
          end
          
          if @inherit_views_exclude_default or !@template.file_exists?(template_path)
            inherit_view_paths.each do |path|
              [:substitute_entire_path, :substitute_root_path, :prepend_path].each do |method|
                inh_path = send(method, template_path, path)
                return inherit_views_set_cached(template_path, inh_path) if @template.file_exists?(inh_path) 
              end
            end
          end
          
          return inherit_views_set_cached(template_path, template_path) unless @inherit_views_exclude_default
      
          raise PathNotFound, "No template found for #{template_path} in '#{self.inherit_view_paths.join("', '")}' (and excluding default path '#{self.class.controller_path}')"
        end
      
      private
        def substitute_entire_path(template_path, path)
          template_path.sub(/^.*\//, path + '/')
        end
      
        def substitute_root_path(template_path, path)
          path + template_path.sub(template_path.sub(/\/.*$/, ''), '')
        end
          
        def prepend_path(template_path, path)
          "#{path}/#{template_path}"
        end
        
        def default_template_name_with_inherit_views(action_name = self.action_name)
          pick_inherited_template_path(default_template_name_without_inherit_views(action_name))
        end
        
        def inherit_views_get_cached(path)
          scope = @inherit_views_exclude_default ? self.inherit_view_paths.first : self.class.controller_path
          self.inherit_view_paths_cache[scope][path]
        end
        
        def inherit_views_set_cached(path, inh_path)
          scope = @inherit_views_exclude_default ? self.inherit_view_paths.first : self.class.controller_path
          self.inherit_view_paths_cache[scope][path] = inh_path
        end
      end
    end
  end
  
  module ActionView
    module InheritViews
      def self.included(base)
        base.class_eval do
          alias_method_chain :render_file, :inherit_views
        end
      end
      
      def parent_views(&block)
        raise "Controller must specify inherit_views to use this method" unless controller.has_inheritable_views
        
        path = @current_render.sub(/\/.*$/, '')
        path = File.dirname(@current_render) unless controller.valid_inherit_views_path?(path)
        controller.parent_views_for(path, &block)
      end
      
      def render_parent(options = {})
        parent_views { render({:file => @current_render, :use_full_path => true}.merge(options)) }
      end
      
      def render_file_with_inherit_views(template_path, use_full_path = true, local_assigns = {})
        orig_current_render = @current_render
        
        template_path = controller.pick_inherited_template_path(template_path) if controller.has_inheritable_views and use_full_path
        
        @current_render = template_path
        render_file_without_inherit_views(template_path, use_full_path, local_assigns)
      ensure
        @current_render = orig_current_render
      end
    end
  end
end