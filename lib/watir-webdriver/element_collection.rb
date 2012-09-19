# encoding: utf-8
module Watir

  #
  # Base class for element collections.
  #

  class ElementCollection
    include Enumerable

    def initialize(parent, selector)
      @parent   = parent
      @selector = selector
    end

    #
    # Yields each element in collection.
    #
    # @example
    #   divs = browser.divs(:class => 'kls')
    #   divs.each do |div|
    #     puts div.text
    #   end
    #
    # @yieldparam [Watir::Element] element Iterate through the elements in this collection.
    #

    def each(&blk)
      to_a.each(&blk)
    end

    #
    # Returns number of elements in collection.
    #
    # @return [Fixnum]
    #

    def length
      elements.length
    end
    alias_method :size, :length

    #
    # Get the element at the given index.
    # Note that this is 0-indexed and not compatible with older Watir implementations.
    #
    # Also note that because of Watir's lazy loading, this will return an Element
    # instance even if the index is out of bounds.
    #
    # @param [Fixnum] idx Index of wanted element, 0-indexed
    # @return [Watir::Element] Returns an instance of a Watir::Element subclass
    #

    def [](idx)
      to_a[idx] || element_class.new(@parent, :index => idx)
    end

    #
    # First element of this collection
    #
    # @return [Watir::Element] Returns an instance of a Watir::Element subclass
    #

    def first
      self[0]
    end

    #
    # Last element of the collection
    #
    # @return [Watir::Element] Returns an instance of a Watir::Element subclass
    #

    def last
      self[-1]
    end

    #
    # This collection as an Array.
    #
    # @return [Array<Watir::Element>]
    #

    def to_a
      # TODO: optimize - lazy element_class instance?
      @to_a ||= elements.map { |e| element_class.new(@parent, :element => e) }
    end

    private

    def elements
      @elements ||= locator_class.new(
        @parent.wd,
        @selector,
        element_class.attribute_list
      ).locate_all
    end

    # overridable by subclasses
    def locator_class
      ElementLocator
    end

  end # ElementCollection
end # Watir
