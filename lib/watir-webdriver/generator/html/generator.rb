module Watir
  module Generator
    class HTML < Base

      private

      def ignored_tags
        # ignore the link element for now
        %w(link)
      end

      def ignored_interfaces
        ignored = ignored_tags.map { |tag| "HTML#{tag.capitalize}Element" }
        # frame is implemented manually, see https://github.com/watir/watir-webdriver/issues/204
        ignored << 'HTMLFrameElement'
      end

      def ignored_attributes
        %w(cells elements hash rows span text)
      end

      def generator_implementation
        'HTML'
      end

      def visitor_class
        HTML::Visitor
      end

      def extractor_class
        HTML::SpecExtractor
      end

    end # Generator
  end # HTML
end # Watir
