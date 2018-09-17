module Watir
  module Generator
    class SVG
      class SpecExtractor < Base::SpecExtractor
        private

        def extract_interface_map
          list = @doc.search("//div[@id='chapter-eltindex']//ul/li")
          list.any? || raise('could not find elements list')

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

              next if external_interface?(id)

              interface_css = 'div.element-summary a.idlinterface'
              interface_definitions = @doc.css("#{id} #{interface_css}, #{id} ~ #{interface_css}")

              # TSpan is defined along with Text so the first IDL definition is SVGTextElement
              idx = tag_name == 'tspan' ? 1 : 0

              result[tag_name] = interface_definitions[idx].inner_text.strip
            end
          end
        end

        def issued_interfaces
          []
        end

        # Some interfaces are actually defined in different specs
        # (for example, clipPath), so we ignore them for now.
        def external_interface?(id)
          id !~ /^#.+/
        end
      end # SpecExtractor
    end # SVG
  end # Generator
end # Watir
