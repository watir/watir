# encoding: utf-8
module Watir
  class ElementCollection
    include Enumerable

    def initialize(parent, element_class)
      @parent, @element_class = parent, element_class
    end

    def each(&blk)
      to_a.each(&blk)
    end

    def length
      elements.length
    end
    alias_method :size, :length

    def [](idx)
      to_a[idx] || @element_class.new(@parent, :index, idx)
    end

    #
    # First element of this collection
    #
    # @return Watir::BaseElement
    #

    def first
      to_a[0] || @element_class.new(@parent, :index, 0)
    end

    #
    # Last element of the collection
    #
    # @return Watir::BaseElement
    #

    def last
      to_a[-1] || @element_class.new(@parent, :index, -1)
    end

    #
    # This collection as an Array
    #
    # @return [Array<Watir::BaseElement>]
    #

    def to_a
      # TODO: optimize - lazily @element_class instance
      @to_a ||= elements.map { |e| @element_class.new(@parent, :element, e) }
    end

    private

    def elements
      @elements ||= ElementLocator.new(
        @parent.wd,
        @element_class.default_selector,
        @element_class.attribute_list
      ).locate_all
    end

  end # ElementCollection
end # Watir
