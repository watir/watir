require 'tsort'

class IDLSorter
  include TSort

  def initialize(interfaces)
    @interfaces = {}

    interfaces.each do |interface|
      @interfaces[interface.name] ||= []
      interface.inherits.each do |inherit|
        (@interfaces[inherit.name] ||= []) << interface.name
      end
    end
  end
  
  def sort
    tsort.reverse
  end

  def tsort_each_node(&blk)
    @interfaces.each_key(&blk)
  end

  def tsort_each_child(node, &blk)
    @interfaces[node].each(&blk)
  end

end
