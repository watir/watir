module Watir
  module Locators
    class TextField
      class SelectorBuilder
        class XPath < Element::SelectorBuilder::XPath
          def build(selector)
            return super if selector.key?(:adjacent)

            selector[:tag_name] = 'input'

            type_string = create_type_string(selector)
            return super(selector) if type_string.nil?

            selector.delete :type
            wd_locator = super(selector)

            start_string = default_start
            input_string = "[local-name()='input']"
            common_string = wd_locator[:xpath].gsub(start_string, '').gsub(input_string, '')

            xpath = "#{start_string}#{input_string}#{type_string}#{common_string}"
            {xpath: xpath}
          end

          protected

          def use_index?
            false
          end

          def add_text
            return '' unless @selector.key?(:text)

            text = @selector.delete :text
            if !text.is_a?(Regexp)
              "[@value=#{XpathSupport.escape text}]"
            elsif XpathSupport.simple_regexp?(text)
              "[contains(@value, '#{text.source}')]"
            else
              @requires_matches[:value] = text
              ''
            end
          end

          private

          def create_type_string(selector)
            if selector[:type].eql?(true)
              "[#{negative_type_text}]"
            elsif Watir::TextField::NON_TEXT_TYPES.include?(selector[:type])
              msg = "TextField Elements can not be located by type: #{selector[:type]}"
              raise LocatorException, msg
            elsif selector[:type].nil?
              "[not(@type) or (#{negative_type_text})]"
            end
          end

          def negative_type_text
            Watir::TextField::NON_TEXT_TYPES.map { |type|
              "#{XpathSupport.downcase '@type'}!=#{XpathSupport.escape type}"
            }.join(' and ')
          end
        end
      end
    end
  end
end
