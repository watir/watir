module Watir
  module Generator
    class SVG < Base
      private

      # fix collisions with HTML
      #
      # TODO: change generator so instead these classes
      # are inherited from HTML ones

      def ignored_tags
        %w[a audio canvas iframe image script source style text title track video unknown]
      end

      def ignored_interfaces
        ignored_tags.map { |tag| "SVG#{tag.capitalize}Element" }
      end

      def ignored_attributes
        []
      end

      def generator_implementation
        'SVG'
      end

      def visitor_class
        SVG::Visitor
      end

      def extractor_class
        SVG::SpecExtractor
      end
    end # SVG
  end # Generator
end # Watir
