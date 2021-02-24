module Watir
  class WindowCollection
    include Enumerable
    include Waitable

    def initialize(browser, selector = {})
      unless selector.keys.all? { |k| %i[title url].include? k }
        raise ArgumentError, "invalid window selector: #{selector.inspect}"
      end

      @browser = browser
      @selector = selector
    end

    #
    # Yields each window in collection.
    #
    # @yieldparam [Watir::Window]
    #

    def each(&blk)
      reset!
      to_a.each(&blk)
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
      new = 'Browser#switch_window or Browser#window with :title, :url selectors'
      reference = 'http://watir.com/window_indexes'
      Watir.logger.deprecate old, new, reference: reference, ids: [:window_index]

      to_a[value]
    end

    def ==(other)
      to_a == other.to_a
    end
    alias eql? ==

    def to_a
      @to_a ||= begin
        all = @browser.driver.window_handles.map { |wh| Window.new(@browser, handle: wh) }
        if @selector.empty?
          all
        else
          all.select do |win|
            @selector.all? { |key, value| win.send(key) =~ /#{value}/ }
          end
        end
      end
    end

    def reset!
      @to_a = nil
    end
  end # Window
end # Watir
