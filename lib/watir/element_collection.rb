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

      build unless @selector.key?(:element)
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

    def build
      selector_builder.build(@selector.dup)
    end

    #
    # Get the element at the given index or range.
    #
    # Any call to an ElementCollection that includes an adjacent selector
    # can not be lazy loaded because it must store the correct type
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
        elements.map.with_index do |el, idx|
          selector = @selector.dup
          selector[:index] = idx unless idx.zero?
          element = element_class.new(@query_scope, selector)
          if [HTMLElement, Input].include? element.class
            construct_subtype(element, hash).tap { |e| e.cache = el }
          else
            element.tap { |e| e.cache = el }
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
      if selector_builder.built.key?(:scope)
        @query_scope.send(:element_call) { locate_all }
      else
        locate_all
      end
    end

    def ensure_context
      @query_scope.locate if @query_scope.relocate?
      @query_scope.switch_to! if @query_scope.is_a?(IFrame)
    end

    def locate_all
      locator.locate_all(selector_builder.built)
    end

    def element_class
      Kernel.const_get(self.class.name.sub(/Collection$/, ''))
    end

    def construct_subtype(element, hash)
      selector = element.selector
      tag_name = selector[:tag_name] || element.tag_name
      hash[tag_name] ||= 0
      hash[tag_name] += 1
      selector[:index] = hash[tag_name] - 1
      selector[:tag_name] = tag_name
      Watir.element_class_for(tag_name).new(@query_scope, selector)
    end
  end # ElementCollection
end # Watir
