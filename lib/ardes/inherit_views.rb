module Ardes# :nodoc:
  module ActionController# :nodoc:
    module InheritViews
      def self.included(base)
        base.class_eval do
          class_inheritable_accessor :inherit_views_from
          self.inherit_views_from = []
          extend ClassMethods
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        def exclude_views_for(controller_sym, &block)
          original = self.inherit_views_from.dup
          self.inherit_views_from.delete(controller_sym)
          result = yield
          self.inherit_views_from = original
          result
        end
        
        def parent_views_for(controller_sym, &block)
          original = self.inherit_views_from.dup
          if i = self.inherit_views_from.index(controller_sym)
            self.inherit_views_from.slice!(0..i)
          end
          result = yield
          self.inherit_views_from = original
          result
        end
      end
      
      module ClassMethods
        # specify this to have your controller inherit its view from the specified controllers
        # or the current controller if no argument is given
        def inherit_views(*controllers)
          controllers = [self.controller_name.to_sym] if controllers.size == 0
          self.inherit_views_from -= controllers
          self.inherit_views_from = controllers + self.inherit_views_from
        end
      end
    end
  end
end
