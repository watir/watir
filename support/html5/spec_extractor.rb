require "nokogiri"
require "open-uri"
require "pp"
require "webidl"

class SpecExtractor
  attr_reader :parse_errors
  
  def initialize(uri)
    @timestamp = Time.now
    @uri = uri
  end

  def process
    download_and_parse
    extract_idl_parts
    extract_interface_map
    build_result
  end

  private

  def download_and_parse
    open(@uri) do |io|
      @doc = Nokogiri.HTML(io)
    end
  end

  def extract_idl_parts
    parsed = @doc.search("//pre[@class='idl']").map {  |e| parse_idl(e.inner_text) }.compact
    
    interfaces = parsed.map { |elements| 
      elements.select { |e| e.kind_of? WebIDL::Ast::Interface  }
    }.flatten
    
    
    @idl = interfaces.group_by { |i| i.name }
  end

  def extract_interface_map
    table = @doc.search("//h3[@id='elements-1']/following-sibling::table[1]").first
    table || raise("could not find elements-1 table")
    
    @interface_map = {}
    
    parse_table(table).inject(@interface_map) do |mem, e|
      e['Element'].split(", ").each do |tag|
        mem[tag] = e['Interface']
      end
      mem
    end
  end
  
  def build_result
    # tag name => Interface instance(s)
    result = {}
    
    @interface_map.each do |tag, interface|
      result[tag] = @idl[interface] || raise("#{interface} not found in IDL")
    end
    
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
      parse_errors << [str, idl_parser.failure_reason]
      nil
    end
  end
  
  def idl_parser
    @idl_parser ||= WebIDL::Parser::IDLParser.new
  end
  
  def parse_errors
    @parse_errors ||= []
  end
  
end
