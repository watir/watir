# require "ruby-debug"
require "#{File.dirname(__FILE__)}/../lib/watir-webdriver/core_ext/string"

module YARD
  module Watir
    class AttributesHandler < YARD::Handlers::Ruby::Base
      handles method_call(:attributes)

      TYPES = {
        :string => "String",
        :bool => "Boolean",
        :int => "Integer"
      }

      def process
        attributes = try_eval

        if attributes.nil?
          p :ignoring => statement.source, :in => namespace.to_s
          return
        end

        TYPES.each do |type, return_type|
          if attributes.member? type
            create_attributes attributes[type], return_type
          end
        end
      end

      private

      def create_attributes(names, return_type)
        names.each do |attribute_name|
          p :adding => "#{namespace}##{attribute_name}"
          attribute_name = "#{attribute_name}?".to_sym if return_type == "Boolean"
          register MethodObject.new(namespace, attribute_name, scope) do |o|
            o.visibility = :public
            o.explicit   = false
            o.docstring.add_tag YARD::Tags::Tag.new(:return, "", return_type)
          end
        end
      end

      def try_eval
        eval "{#{statement.parameters.source}}"
      rescue SyntaxError, StandardError
        nil
      end

    end # AttributesHandler

    class ContainerMethodHandler < YARD::Handlers::Ruby::Base
      handles method_call(:container_method)

      def process
        name = statement.parameters.flatten.first
        return_type = namespace.to_s
        p :adding => "Watir::Container##{name}"

        register MethodObject.new(P("Watir::Container"), name, :instance) do |o|
          o.docstring.add_tag(YARD::Tags::Tag.new(:return, "", return_type))
        end
      end
    end # ContainerMethodHandler

    class CollectionMethodHandler < YARD::Handlers::Ruby::Base
      handles method_call(:collection_method)

      def process
        name = statement.parameters.flatten.first
        p :adding => "Watir::Container##{name}"

        class_name  = "#{name.to_s.camel_case}Collection"
        return_type = "Watir::#{class_name}"

        register MethodObject.new(P("Watir::Container"), name, :instance) do |o|
          o.docstring.add_tag(YARD::Tags::Tag.new(:return, "", return_type))
        end

        register ClassObject.new(P("Watir"), class_name) do |o|
          o.superclass = "Watir::ElementCollection"
        end
      end
    end # CollectionMethodHandler

  end # Watir
end # YARD