module Watir
  module Generator
    class HTML
      class Visitor < Base::Visitor
        def classify_regexp
          /^HTML(.+)Element$/
        end

        private

        def interface_regexp
          /^HTML/
        end

        def force_inheritance
          {'HTMLElement' => 'Element'}
        end
      end # Visitor
    end # HTML
  end # Generator
end # Watir
