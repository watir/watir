module YARD
  module Handlers
    module Watir
      #
      # @private
      #

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
            p :ignoring => statement.source, :in => namespace.to_s if $DEBUG
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
            p :adding => "#{namespace}##{attribute_name}" if $DEBUG
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
    end # Watir
  end # Handlers
end # YARD
