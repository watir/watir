require "nokogiri"
require "open-uri"
require "pp"
require "ruby-debug"

class IdlExtractor
  def initialize(url)
    @doc = Nokogiri.HTML(open(url))
  end
  
  def write_to(filepath)
    idls = parse_idls
    pp idls
    # File.open(filepath, "w") do |file|
    #   idls.each { |idl| file.puts(idl) }
    # end
  end
  
  def parse_idls
    element_headers = @doc.search('//h4').select { |e| e['id'] =~ /^the-.+-elements?$/ }
    element_headers.map { |e| extract_idl_from(e) }
  end
  
  def extract_idl_from(node)
    idl = []
    idl << "// #{node['id']}"
    
    dd = node.search('//following-sibling::dt[text()="DOM interface:"]/following-sibling::dd').first
    raise "could not find 'DOM interface' section for #{node.inspect}" unless dd
    debugger
    # if dd.css("pre.idl")
    
    idl.join("\n")
  end
end

