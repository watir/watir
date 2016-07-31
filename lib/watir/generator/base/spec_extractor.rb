module Watir
  module Generator
    class Base::SpecExtractor

      IDL_SELECTOR = "//pre[@class='idl']"

      class InterfaceNotFound < StandardError; end

      def initialize(uri)
        @uri = uri
      end

      def process
        download_and_parse
        extract_idl_parts
        extract_interface_map
        drop_issued_interfaces
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
        parsed = @doc.search(IDL_SELECTOR).map {  |e| parse_idl(e.inner_text) }.compact

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
        raise NotImplementedError
      end

      def drop_issued_interfaces
        @interface_map.delete_if do |_, interface|
          issued_interfaces.include?(interface)
        end
      end

      def build_result
        raise NotImplementedError
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
          final.inherits += intf.inherits
          final.members += intf.members
          final.extended_attributes += intf.extended_attributes
        end

        @interfaces = non_duplicates
      end

      def idl_parser
        @idl_parser ||= WebIDL::Parser::IDLParser.new
      end

      def sorter
        @idl_sorter ||= Base::IDLSorter.new(@interfaces)
      end

    end # SpecExtractor
  end # Generator
end # Watir
