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

    alias length count
    alias size count

    alias empty? none?

    #
    # Get the element at the given index or range.
    #
    # Any call to an ElementCollection including an adjacent selector
    # can not be lazy loaded because it must store correct type
    #
    # Ranges can not be lazy loaded
    #
    # @param [Integer, Range] value Index (0-based) or Range of desired element(s)
    # @return [Watir::Element, Watir::ElementCollection] Returns an instance of a Watir::Element subclass
    #

    def [](value)
      if value.is_a?(Range)
        to_a[value]
      elsif @selector.key? :adjacent
        to_a[value] || element_class.new(@query_scope, invalid_locator: true)
      elsif @to_a && @to_a[value]
        @to_a[value]
      else
        element_class.new(@query_scope, @selector.merge(index: value))
      end
    end

    #
    # First element of the collection
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
      hash = {}
      @to_a ||=
        elements.map.with_index do |e, idx|
          selector = @selector.merge(element: e)
          selector[:index] = idx
          element = element_class.new(@query_scope, selector)
          if [HTMLElement, Input].include? element.class
            tag_name = @selector[:tag_name] || element.tag_name
            hash[tag_name] ||= 0
            hash[tag_name] += 1
            selector[:index] = hash[tag_name] - 1
            selector[:tag_name] = tag_name
            Watir.element_class_for(tag_name).new(@query_scope, selector)
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
    # Returns browser.
    #
    # @return [Watir::Browser]
    #

    def browser
      @query_scope.browser
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
    alias eql? ==

    #
    # Creates a Collection containing elements of two collections.
    #
    # @example
    #   options = browser.select_list(name: "new_user_languages").options
    #   (options + browser.select_list(id: "new_user_role").options).size
    #   #=> 8
    #

    private

    def elements
      ensure_context
      if @query_scope.is_a?(Browser)
        locate_all
      else
        # This gives all of the standard Watir waiting behaviors to Collections
        @query_scope.send(:element_call) { locate_all }
      end
    end

    def ensure_context
      @query_scope.locate if @query_scope.relocate?
      @query_scope.switch_to! if @query_scope.is_a?(IFrame)
    end

    def locate_all
      build_locator.locate_all
    end

    def element_class
      Kernel.const_get(self.class.name.sub(/Collection$/, ''))
    end
  end # ElementCollection
end # Watir
