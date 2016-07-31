module Watir
  module Generator
    class HTML::Visitor < Base::Visitor

      def classify_regexp
        /^HTML(.+)Element$/
      end

      private

      def interface_regexp
        /^HTML/
      end

      def force_inheritance
        { 'HTMLElement' => 'Element' }
      end

    end # HTML::Visitor
  end # Generator
end # Watir
