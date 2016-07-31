module Watir
  module Generator
    class SVG::SpecExtractor < Base::SpecExtractor

      private

      def extract_interface_map
        list = @doc.search("//div[@id='chapter-eltindex']//ul/li")
        list.any? or raise 'could not find elements list'

        @interface_map = parse_list(list)
      end

      def build_result
        {}.tap do |result|
          @interface_map.each do |tag, interface|
            result[tag] = fetch_interface(interface)
          end
        end
      end

      def parse_list(list)
        {}.tap do |result|
          list.each do |node|
            tag_name = node.css('a span').inner_text.strip
            id = node.css('a').attr('href').to_s

            # Some interfaces are actually defined in different specs
            # (for example, clipPath), so we ignore them for now
            if id =~ /^#.+/
              interface_css = 'div.element-summary a.idlinterface'
              interface_name = @doc.css("#{id} #{interface_css}, #{id} ~ #{interface_css}").first.inner_text.strip

              result[tag_name] = interface_name
            end
          end
        end
      end

      def issued_interfaces
        %w(SVGHatchElement SVGHatchPathElement SVGSolidColorElement)
      end

    end # SVG::SpecExtractor
  end # Generator
end # Watir
