module Watir
  class WindowCollection
    include Enumerable

    def initialize(windows)
      @windows = windows
    end

    #
    # Yields each window in collection.
    #
    # @yieldparam [Watir::Window]
    #

    def each(&blk)
      @windows.each(&blk)
    end

    alias length count
    alias size count
    alias empty? none?

    #
    # First window of the collection
    #
    # @note windows in a collection are not ordered so this is not reliably
    # @deprecated use Browser#switch_window or a better Window locator
    # @return [Watir::Window] Returns an instance of a Watir::Window
    #

    def first
      self[0]
    end

    #
    # Last window of the collection
    #
    # @note windows in a collection are not ordered so this is not reliably
    # @deprecated use Browser#switch_window or a better Window locator
    # @return [Watir::Window] Returns an instance of a Watir::Window
    #

    def last
      self[-1]
    end

    #
    # Get the window at the given index or range.
    #
    # @note windows in a collection are not ordered so this is not reliably
    # @deprecated use Browser#switch_window or a better Window locator
    # @param [Integer, Range] value Index (0-based) or Range of desired window(s)
    # @return [Watir::Window] Returns an instance of a Watir::Window
    #

    def [](value)
      old = 'using indexing with windows'
      new = 'Browser#switch_window or Browser#window with :title, :url or :element selectors'
      reference = 'http://watir.com/window_indexes'
      Watir.logger.deprecate old, new, reference: reference, ids: [:window_index]

      to_a[value]
    end

    def ==(other)
      to_a == other.to_a
    end
    alias eql? ==
  end # Window
end # Watir
