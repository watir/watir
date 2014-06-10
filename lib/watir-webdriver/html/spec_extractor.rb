# encoding: utf-8

module Watir
  module HTML
    class SpecExtractor

      class InterfaceNotFound < StandardError
      end

      def initialize(uri)
        @uri = uri
      end

      def process
        download_and_parse
        extract_idl_parts
        extract_interface_map
        build_result
      rescue
        p errors
        raise
      end

      def errors
        @errors ||= []
      end

      #
      # returns a topoligically sorted array of WebIDL::Ast::Interface objects
      #

      def sorted_interfaces
        process if @interfaces.nil?

        sorter.sort.map { |name|
          @interfaces.find { |i| i.name == name } or puts "ignoring interface: #{name}"
        }.compact
      end

      def print_hierarchy
        process if @interfaces.nil?
        sorter.print
      end

      def fetch_interface(interface)
        @interfaces_by_name[interface] or raise InterfaceNotFound, "#{interface} not found in IDL"
      end

      private

      def download_and_parse
        open(@uri) { |io| @doc = Nokogiri.HTML(io) }
      end

      def extract_idl_parts
        parsed = @doc.search("//pre[@class='idl']").map {  |e| parse_idl(e.inner_text) }.compact

        implements = []
        @interfaces = []

        parsed.flatten.each do |element|
          case element
          when WebIDL::Ast::Interface
            @interfaces << element
          when WebIDL::Ast::ImplementsStatement
            implements << element
          end
        end

        @interfaces_by_name = @interfaces.group_by(&:name)
        apply_implements(implements)
        merge_interfaces
      end

      def extract_interface_map
        # http://www.whatwg.org/specs/web-apps/current-work/#elements-1
        table = @doc.search("//h3[@id='elements-1']/following-sibling::table[1]").first
        table or raise "could not find elements-1 table"

        @interface_map = {}

        parse_table(table).each do |row|
          row['Element'].split(", ").each { |tag| @interface_map[tag] = row['Interface'] }
        end
      end

      def build_result
        # tag name => Interface instance(s)
        result = {}

        @interface_map.each do |tag, interface|
          result[tag] = fetch_interface(interface)
        end

        # missing from the elements-1 table
        result['frameset'] = fetch_interface('HTMLFrameSetElement')

        result
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

      def parse_idl(str)
        result = idl_parser.parse(str)

        if result
          result.build
        else
          errors << idl_parser.failure_reason
          nil
        end
      end

      def apply_implements(implements)
        implements.each do |is|
          implementor_name = is.implementor.gsub(/^::/, '')
          implementee_name = is.implementee.gsub(/^::/, '')

          begin
            intf = fetch_interface(implementor_name).first
            intf.implements << fetch_interface(implementee_name).first
          rescue InterfaceNotFound => ex
            puts ex.message
          end
        end
      end

      def merge_interfaces
        non_duplicates = @interfaces.uniq(&:name)
        duplicates = @interfaces - non_duplicates

        duplicates.each do |intf|
          final = non_duplicates.find { |i| i.name == intf.name }
          final.members += intf.members
          final.extended_attributes += intf.extended_attributes
        end

        @interfaces = non_duplicates
      end

      def idl_parser
        @idl_parser ||= WebIDL::Parser::IDLParser.new
      end

      def sorter
        @idl_sorter ||= IDLSorter.new(@interfaces)
      end

    end # SpecExtractor
  end # HTML
end # Watir
