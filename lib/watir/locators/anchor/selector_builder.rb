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
          return unless convert_to_partial_link_text?(selector)

          selector.delete(:tag_name)
          {partial_link_text: selector.delete(:visible_text).source}
        end

        def convert_to_partial_link_text?(selector)
          selector.keys.sort == %i[tag_name visible_text] &&
            RegexpDisassembler.new(selector[:visible_text]).substrings.first == selector[:visible_text].source
        end
      end
    end
  end
end
