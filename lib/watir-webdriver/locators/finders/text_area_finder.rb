module Watir
  class TextAreaLocator
    class Finder < ElementLocator::Finder
      private

      def can_convert_regexp_to_contains?
        false
      end
    end
  end
end
