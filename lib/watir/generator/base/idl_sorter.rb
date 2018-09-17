require 'tsort'

module Watir
  module Generator
    class Base
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

        def print
          @visited = []
          sort.each { |node| print_node(node) }
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

        private

        def print_node(node, indent = 0)
          return if @visited.include?(node)

          @visited << node
          puts ' ' * indent + node
          tsort_each_child(node) { |child| print_node(child, indent + 2) }
        end
      end # IDLSorter
    end # Base
  end # Generator
end # Watir
