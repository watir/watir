module Watir
  class TextArea
    class Finder < Element::Finder
      private

      def can_convert_regexp_to_contains?
        false
      end
    end
  end
end
