module Watir
  module Locators
    class Button
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def build(selector)
            return super if selector.key?(:adjacent)

            selector[:tag_name] = 'button'

            type = selector.delete :type
            return super(selector) if type.eql?(false)

            # both :value and :text selectors will locate elements by value attribute or text content
            selector[:text] = selector.delete(:value) if selector.key?(:value)

            wd_locator = super(selector)

            start_string = default_start

            button_string = "local-name()='button'"
            common_string = wd_locator[:xpath].gsub(start_string, '').gsub("[#{button_string}]", '')

            input_string = "(local-name()='input' and #{input_types(type)})"

            tag_string = if type.nil?
                           "[#{button_string} or #{input_string}]"
                         else
                           "[#{input_string}]"
                         end

            xpath = "#{start_string}#{tag_string}#{common_string}"

            {xpath: xpath}
          end

          protected

          # This is special because text locator for buttons match text or value
          def add_text
            return '' unless @selector.key?(:text)

            text = @selector.delete :text
            if !text.is_a?(Regexp)
              "[normalize-space()='#{text}' or @value='#{text}']"
            elsif simple_regexp?(text)
              "[contains(text(), '#{text.source}') or contains(@value, '#{text.source}')]"
            else
              @selector[:text] = text
              ''
            end
          end

          private

          def input_types(type)
            types = if [nil, true].include?(type)
                      Watir::Button::VALID_TYPES
                    elsif !Watir::Button::VALID_TYPES.include?(type)
                      msg = "Button Elements can not be located by input type: #{type}"
                      raise LocatorException, msg
                    else
                      [type]
                    end
            types.map { |button_type|
              "#{XpathSupport.downcase '@type'}=#{XpathSupport.escape button_type}"
            }.compact.join(' or ')
          end
        end
      end
    end
  end
end
