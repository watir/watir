module Watir
  class WindowCollection
    include Enumerable
    include Waitable

    def initialize(browser, selector = {})
      unless selector.keys.all? { |k| %i[title url element].include? k }
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
      window_list.each(&blk)
    end

    alias length count
    alias size count
    alias empty? none?

    def [](*)
      raise NoMethodError, 'indexing not reliable on WindowCollection'
    end
    alias first []
    alias last []
    alias to_a []

    def ==(other)
      window_list == other.send(:window_list)
    end
    alias eql? ==

    def restore!
      return if @browser.closed?

      window_list.reject { |win| win.handle == @browser.original_window.handle }.each(&:close)
      @browser.original_window.use
    rescue StandardError
      @browser.close
    end

    def reset!
      @window_list = nil
    end

    private

    def window_list
      @window_list ||= begin
        handles = @browser.driver.window_handles.select { |wh| matches?(wh) }
        handles.map { |wh| Window.new(@browser, handle: wh) }
      end
    end

    # NOTE: This is the exact same code from `Window#matches?`
    # TODO: Move this code into a separate WindowLocator class
    def matches?(handle)
      @selector.empty? || @browser.driver.switch_to.window(handle) do
        matches_title = @selector[:title].nil? || @browser.title =~ /#{@selector[:title]}/
        matches_url = @selector[:url].nil? || @browser.url =~ /#{@selector[:url]}/
        matches_element = @selector[:element].nil? || @selector[:element].exists?

        matches_title && matches_url && matches_element
      end
    rescue Selenium::WebDriver::Error::NoSuchWindowError
      # the window may disappear while we're iterating.
      false
    end
  end # Window
end # Watir
