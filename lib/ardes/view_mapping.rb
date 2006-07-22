module Ardes# :nodoc:
  module ActionController# :nodoc:
    module ViewMapping
      def self.included(base)
        base.class_eval do
          class_inheritable_accessor :view_mappings
          self.view_mappings    = {}
          extend ClassMethods
        end
      end
      
      module ClassMethods
        def view_mapping(mapping)
          sanitized = {}
          mapping.each {|k,v| sanitized[k.to_s] = v.to_s}
          self.view_mappings = self.view_mappings.merge sanitized
        end
      end
    end
  end

  module ActionView
    module ViewMapping
      def self.included(base)
        base.alias_method_chain :full_template_path, :view_mapping
      end

    private
      def full_template_path_with_view_mapping(template_path, extension)
        path = template_path.sub(/\/.*$/, '')
        if controller.view_mappings.key? path
          template_path = template_path.sub(path, controller.view_mappings[path])
          return "#{template_path}.#{extension}" if template_path.slice(0,1) == '/'
        end
        full_template_path_without_view_mapping(template_path, extension)
      end
    end
  end
end