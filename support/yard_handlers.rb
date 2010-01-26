require "ruby-debug"

module YARD
  module Watir
    class AttributesHandler < YARD::Handlers::Ruby::Base
      handles method_call(:attributes)

      def process
        attributes = try_eval

        if attributes.nil?
          p :ignoring => statement.source, :in => namespace.to_s
          return
        end

        if attributes.member?(:string)
          attributes[:string].each do |attribute_name|
            p :adding => "#{namespace}##{attribute_name}"
            register MethodObject.new(namespace, attribute_name, scope) do |o|
              o.visibility = :public
              o.signature = "def #{attribute_name}"
            end
          end
        end

        if attributes.member?(:bool)
          attributes[:bool].each do |attribute_name|
            p :adding => "#{namespace}##{attribute_name}"
            register MethodObject.new(namespace, "#{attribute_name}?", scope) do |o|
              o.visibility = :public
              o.signature = "def #{attribute_name}?"
            end
          end
        end

        if attributes.member?(:int)
          attributes[:int].each do |attribute_name|
            p :adding => "#{namespace}##{attribute_name}"
            register MethodObject.new(namespace, attribute_name, scope) do |o|
              o.visibility = :public
              o.signature = "def #{attribute_name}"
            end
          end
        end
      end

      private

      def try_eval
        eval "{#{statement.parameters.source}}"
      rescue Exception
        nil
      end

    end # AttributesHandler

    class FactoryMethodHandler < YARD::Handlers::Ruby::Base
      handles method_call(:collection_method)
      handles method_call(:container_method)

      def process
        name = statement.parameters.flatten.first

        p :adding => "Watir::Container##{name}"

        register MethodObject.new(P("Watir::Container"), name, :instance)
      end
    end

  end # Watir
end # YARD