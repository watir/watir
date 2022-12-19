# frozen_string_literal: true

module Watir
  module Locators
    class Button
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          private

          def tag_string
            return super if @adjacent

            # Selector builder ignores tag name and builds for both button elements and input elements of type button
            @selector.delete(:tag_name)

            type = @selector.delete(:type)
            text = @selector.delete(:text)

            button = "(#{button_string(text: text, type: type)})"
            input = type.eql?(false) ? '' : " or (#{input_string(text: text, type: type)})"

            "[#{button}#{input}]"
          end

          def button_string(text: nil, type: nil)
            input = type.nil? ? '' : " and #{input_types(type)}"
            attribute = text.nil? ? '' : " and #{process_attribute(:text, text)}"
            "#{process_attribute(:tag_name, 'button')}#{input}#{attribute}"
          end

          def input_string(text: nil, type: nil)
            type = nil if type.eql?(true)
            text_value = text.nil? ? '' : " and #{process_attribute(:value, text)}"
            @built.delete(:value) unless text.nil?
            "#{process_attribute(:tag_name, 'input')} and (#{input_types(type)})#{text_value}"
          end

          # value locator needs to match input value, button text or button value
          def text_string
            return super if @adjacent

            # :text locator is already dealt with in #tag_name_string
            value = @selector.delete(:value)

            return '' if value.nil?

            result = value.nil? ? '' : "[#{process_attribute(:text, value)} or #{process_attribute(:value, value)}]"
            @built.delete(:text)
            result
          end

          def input_types(type = nil)
            types = if type.eql?(nil)
                      Watir::Button::VALID_TYPES
                    elsif Watir::Button::VALID_TYPES.include?(type) || type.eql?(true) || type.eql?(false)
                      [type]
                    else
                      msg = "Button Elements can not be located by input type: #{type}"
                      raise LocatorException, msg
                    end
            types.map { |button_type|
              predicate_expression(:type, button_type)
            }.compact.join(' or ')
          end
        end
      end
    end
  end
end
