module Watir

  #
  # Base class for element collections.
  #

  class ElementCollection
    include Enumerable
    include Locators::ClassHelpers

    def initialize(query_scope, selector)
      @query_scope = query_scope
      @selector = selector
    end

    #
    # Yields each element in collection.
    #
    # @example
    #   divs = browser.divs(class: 'kls')
    #   divs.each do |div|
    #     puts div.text
    #   end
    #
    # @yieldparam [Watir::Element] element Iterate through the elements in this collection.
    #

    def each(&blk)
      to_a.each(&blk)
    end

    alias_method :length, :count
    alias_method :size, :count

    alias_method :empty?, :none?

    #
    # Get the element at the given index.
    #
    # Also note that because of Watir's lazy loading, this will return an Element
    # instance even if the index is out of bounds.
    #
    # @param [Integer] idx Index of wanted element, 0-indexed
    # @return [Watir::Element] Returns an instance of a Watir::Element subclass
    #

    def [](idx)
      element_class.new(@query_scope, @selector.merge(index: idx))
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
      hash = {}
      @to_a ||=
          elements.map.with_index do |e, idx|
            element = element_class.new(@query_scope, @selector.merge(element: e, index: idx))
            if [Watir::HTMLElement, Watir::Input].include? element.class
              tag_name = element.tag_name.to_sym
              hash[tag_name] ||= 0
              hash[tag_name] += 1
              Watir.tag_to_class[tag_name].new(@query_scope, @selector.merge(element: e,
                                                                             tag_name: tag_name,
                                                                             index: hash[tag_name] - 1))
            else
              element
            end
          end
    end

    #
    # Locate all elements and return self.
    #
    # @return ElementCollection
    #

    def locate
      to_a
      self
    end

    #
    # Returns true if two element collections are equal.
    #
    # @example
    #   browser.select_list(name: "new_user_languages").options == browser.select_list(id: "new_user_languages").options
    #   #=> true
    #
    # @example
    #   browser.select_list(name: "new_user_role").options == browser.select_list(id: "new_user_languages").options
    #   #=> false
    #

    def ==(other)
      to_a == other.to_a
    end
    alias_method :eql?, :==

    #
    # Creates a Collection containing elements of two collections.
    #
    # @example
    #   (browser.select_list(name: "new_user_languages").options + browser.select_list(id: "new_user_role").options).size
    #   #=> 8
    #

    private

    def elements
      @locator ||= build_locator
      @elements ||= @locator.locate_all
    end

    def element_class
      Kernel.const_get(self.class.name.sub(/Collection$/, ''))
    end

  end # ElementCollection
end # Watir
