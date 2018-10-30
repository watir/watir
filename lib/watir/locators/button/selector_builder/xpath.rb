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

            string = "(#{button_string(text: text, type: type)})"
            string << " or (#{input_string(text: text, type: type)})" unless type.eql?(false)
            "[#{string}]"
          end

          def button_string(text: nil, type: nil)
            string = process_attribute(:tag_name, 'button')
            string << " and #{process_attribute(:text, text)}" unless text.nil?
            string << " and #{input_types(type)}" unless type.nil?
            string
          end

          def input_string(text: nil, type: nil)
            string = process_attribute(:tag_name, 'input')
            type = nil if type.eql?(true)
            string << " and (#{input_types(type)})"
            if text
              string << " and #{process_attribute(:value, text)}"
              @built.delete(:value)
            end
            string
          end

          # value locator needs to match input value, button text or button value
          def text_string
            return super if @adjacent

            # :text locator is already dealt with in #tag_name_string
            value = @selector.delete(:value)

            case value
            when nil
              ''
            when Regexp
              res = "[#{predicate_conversion(:text, value)} or #{predicate_conversion(:value, value)}]"
              @built.delete(:text)
              res
            else
              "[#{predicate_expression(:text, value)} or #{predicate_expression(:value, value)}]"
            end
          end

          def predicate_conversion(key, regexp)
            res = key == :text ? super(:contains_text, regexp) : super
            @built[key] = @built.delete(:contains_text) if @built.key?(:contains_text)
            res
          end

          def input_types(type = nil)
            types = if type.eql?(nil)
                      Watir::Button::VALID_TYPES
                    elsif Watir::Button::VALID_TYPES.include?(type)
                      [type]
                    elsif type.eql?(true) || type.eql?(false)
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
