require "nokogiri"
require "open-uri"
require "pp"
require "ruby-debug"

class IdlExtractor
  def initialize(url)
    @doc    = Nokogiri.HTML(open(url))
    @idls   = {}
    @extras = {}
    extract
  end

  def write_idl_to(filepath)
    File.open(filepath, "w") do |file|
      @idls.values.each { |idl| file.puts(idl) }
    end
  end

  def write_extras_to(filepath)
    File.open(filepath, "w") do |file|
      @extras.values.each { |extra| file.puts(extra) }
    end
  end

  def extract
    # get the HTMLElement interface, which doesn't follow the normal structure
    unless html_header = @doc.search("//h4[@id='elements-in-the-dom']").first
      raise "could not find header with id 'elements-in-the-dom' (for HTMLElement)"
    end

    idl = html_header.xpath("following-sibling::pre[@class='idl']").first.text
    @idls['htmlelement'] = "// HTMLElement\n#{idl}"

    # then get all the others
    element_headers = @doc.search('//h4').select { |e| e['id'] =~ /the-.+-element/ }
    raise "no elements found in the spec!" if element_headers.empty?
    element_headers.map { |e| extract_idl_from(e) }
  end


  def extract_idl_from(node)
    dl = node.xpath("following-sibling::dl[@class='element' and position()=1]").first
    unless dl
      short_id = node['id'][/^the-.+-element/, 0]
      $stderr.puts "could not find 'DOM interface' section for #{node['id']}"
      $stderr.puts "   already have #{short_id}" if @idls.has_key?(short_id) || @extras.has_key?(short_id)
      return
    end

    prefix = "\n\n// #{node['id']}\n" << tag_name_ext_attr_for(node)

    if idl_node = dl.css("pre.idl").first
      @idls[node['id']] = prefix << idl_node.text
    else
      if extra_node = dl.css("dt ~ dd").last
        @extras[node['id']] = prefix << extra_node.text
      else
        raise "could not find IDL section for #{node['id']}"
      end
    end
  end

  def tag_name_ext_attr_for(node)
    if node['id'] =~ /^the-(.+)-element/
      "[TagName=#{$1}]\n"
    else
      raise "not sure what tag name to use for #{node['id']}"
    end
  end

end # IdlExtractor

