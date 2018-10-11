module Watir
  module Locators
    class Anchor
      class SelectorBuilder < Element::SelectorBuilder
        private

        def build_wd_selector(selector)
          build_link_text(selector) || build_partial_link_text(selector) || super
        end

        def build_link_text(selector)
          return unless can_convert_to_link_text?(selector)

          selector.delete(:tag_name)
          {link_text: selector.delete(:visible_text)}
        end

        def can_convert_to_link_text?(selector)
          selector.keys.sort == %i[tag_name visible_text] &&
            selector[:visible_text].is_a?(String)
        end

        def build_partial_link_text(selector)
          return unless can_convert_to_partial_link_text?(selector)

          selector.delete(:tag_name)
          {partial_link_text: selector.delete(:visible_text).source}
        end

        def can_convert_to_partial_link_text?(selector)
          selector.keys.sort == %i[tag_name visible_text] &&
            XpathSupport.simple_regexp?(selector[:visible_text])
        end
      end
    end
  end
end
