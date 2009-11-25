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
      to_a.length
    end
    alias_method :size, :length

    def [](idx)
      to_a[idx] || @element_class.new(@parent, :index, idx)
    end

    def first
      to_a[0] || @element_class.new(@parent, :index, 0)
    end

    def last
      to_a[-1] || @element_class.new(@parent, :index, -1)
    end

    def to_a
      # TODO: optimize - lazily @element_class instance
      @to_a ||= elements.map { |e| @element_class.new(@parent, :element, e) }
    end

    def elements
      @elements ||= ElementLocator.new(driver, @element_class.default_selector).locate_all
    end

    def driver
      @parent.driver
    end

  end # ElementCollection
end # Watir
