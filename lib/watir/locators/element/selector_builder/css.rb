module Watir
  module Locators
    class Element
      class SelectorBuilder
        class CSS
          def build(selectors)
            return unless use_css?(selectors)

            if selectors.empty?
              css = '*'
            else
              css = ''
              css << (selectors.delete(:tag_name) || '')

              klass = selectors.delete(:class)
              if klass
                if klass.include? ' '
                  css << %([class="#{css_escape klass}"])
                else
                  css << ".#{klass}"
                end
              end

              href = selectors.delete(:href)
              if href
                css << %([href~="#{css_escape href}"])
              end

              selectors.each do |key, value|
                key = key.to_s.tr("_", "-")
                css << %([#{key}="#{css_escape value}"]) # TODO: proper escaping
              end
            end

            [:css, css]
          end

          private

          def use_css?(selectors)
            return false unless Watir.prefer_css?

            if selectors.key?(:text) || selectors.key?(:label) || selectors.key?(:index)
              return false
            end

            if selectors[:tag_name] == 'input' && selectors.key?(:type)
              return false
            end

            if selectors.key?(:class) && selectors[:class] !~ /^[\w-]+$/ui
              return false
            end

            true
          end

          def css_escape(str)
            str.gsub('"', '\\"')
          end
        end
      end
    end
  end
end
