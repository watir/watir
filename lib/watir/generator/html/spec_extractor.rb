module Watir
  module Generator
    class HTML::SpecExtractor < Base::SpecExtractor

      private

      def extract_interface_map
        # http://www.whatwg.org/specs/web-apps/current-work/#elements-1
        table = @doc.search("//h3[@id='elements-3']/following-sibling::table[1]").first
        table or raise "could not find elements-3 table"

        @interface_map = {}

        parse_table(table).each do |row|
          row['Element'].split(", ").each { |tag| @interface_map[tag] = row['Interface'] }
        end
      end

      def build_result
        {}.tap do |result|
          @interface_map.each do |tag, interface|
            result[tag] = fetch_interface(interface)
          end

          # missing from the elements-1 table
          result['frameset'] = fetch_interface('HTMLFrameSetElement')
        end
      end

      def parse_table(table)
        headers = table.css("thead th").map { |e| e.inner_text.strip }

        table.css("tbody tr").map do |row|
          result = {}

          row.css("th, td").each_with_index do |node, idx|
            result[headers[idx]] = node.inner_text.strip
          end

          result
        end
      end

      def issued_interfaces
        []
      end

    end # HTML:;SpecExtractor
  end # Generator
end # Watir
