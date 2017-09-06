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
      to_a[idx] || element_class.new(@query_scope, @selector.merge(index: idx))
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
              element = element.to_subtype
              hash[element.class] ||= []
              hash[element.class] << element
              element.class.new(@query_scope, @selector.merge(element: e,
                                                              tag_name: element.tag_name,
                                                              index: hash[element.class].size - 1))
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
      @query_scope.send :ensure_context

      element_validator = element_validator_class.new
      selector_builder = selector_builder_class.new(@query_scope, @selector, element_class.attribute_list)
      locator = locator_class.new(@query_scope, @selector, selector_builder, element_validator)

      @elements ||= locator.locate_all
    end

    def element_class
      Kernel.const_get(self.class.name.sub(/Collection$/, ''))
    end

  end # ElementCollection
end # Watir
