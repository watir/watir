module Watir
  class Window
    include EventuallyPresent
    include Waitable
    include Exception

    attr_reader :browser

    def initialize(browser, selector)
      @browser = browser
      @driver = browser.driver
      @selector = selector

      if selector.empty?
        @handle = current_window
      elsif selector.key? :handle
        @handle = selector.delete :handle
      else
        return if selector.keys.all? { |k| %i[title url index].include? k }

        raise ArgumentError, "invalid window selector: #{selector_string}"
      end
    end

    def inspect
      format('#<%s:0x%x located=%s>', self.class, hash * 2, !!@handle)
    end

    #
    # Returns window size.
    #
    # @example
    #   size = browser.window.size
    #   [size.width, size.height] #=> [1600, 1200]
    #

    def size
      use { return @driver.manage.window.size }
    end

    #
    # Returns window position.
    #
    # @example
    #   position = browser.window.position
    #   [position.x, position.y] #=> [92, 76]
    #

    def position
      use { return @driver.manage.window.position }
    end

    #
    # Resizes window to given width and height.
    #
    # @example
    #   browser.window.resize_to 1600, 1200
    #
    # @param [Integer] width
    # @param [Integer] height
    #

    def resize_to(width, height)
      Selenium::WebDriver::Dimension.new(Integer(width), Integer(height)).tap do |dimension|
        use { @driver.manage.window.size = dimension }
      end
    end

    #
    # Moves window to given x and y coordinates.
    #
    # @example
    #   browser.window.move_to 300, 200
    #
    # @param [Integer] x_coord
    # @param [Integer] y_coord
    #

    def move_to(x_coord, y_coord)
      Selenium::WebDriver::Point.new(Integer(x_coord), Integer(y_coord)).tap do |point|
        use { @driver.manage.window.position = point }
      end
    end

    #
    # Maximizes window.
    #
    # @example
    #   browser.window.maximize
    #

    def maximize
      use { @driver.manage.window.maximize }
    end

    #
    # Returns true if window exists.
    #
    # @return [Boolean]
    #

    def exists?
      assert_exists
      true
    rescue NoMatchingWindowFoundException
      false
    end

    alias present? exists?
    alias exist? exists?

    #
    # Returns true if two windows are equal.
    #
    # @example
    #   browser.window(index: 0) == browser.window(index: 1)
    #   #=> false
    #
    # @param [Window] other
    #

    def ==(other)
      return false unless other.is_a?(self.class)

      handle == other.handle
    end
    alias eql? ==

    def hash
      handle.hash ^ self.class.hash
    end

    #
    # Returns true if window is current.
    #
    # @example
    #   browser.window.current?
    #   #=> true
    #

    def current?
      current_window == handle
    end

    #
    # Closes window.
    #

    def close
      @browser.original_window = nil if self == @browser.original_window
      use { @driver.close }
    end

    #
    # Returns window title.
    #
    # @return [String]
    #

    def title
      use { return @driver.title }
    end

    #
    # Returns window URL.
    #
    # @return [String]
    #

    def url
      use { return @driver.current_url }
    end

    #
    # Switches to given window and executes block, then switches back.
    #
    # @example
    #   browser.window(title: "closeable window").use do
    #     browser.a(id: "close").click
    #   end
    #

    def use(&blk)
      @browser.original_window ||= current_window
      wait_for_exists
      @driver.switch_to.window(handle, &blk)
      self
    end

    #
    # @api private
    #
    # Referenced in EventuallyPresent
    #

    def selector_string
      @selector.inspect
    end

    def handle
      @handle ||= locate
    end

    private

    def locate
      if @selector.empty?
        nil
      elsif @selector.key?(:index)
        @driver.window_handles[Integer(@selector[:index])]
      else
        @driver.window_handles.find { |wh| matches?(wh) }
      end
    end

    def assert_exists
      return if @driver.window_handles.include?(handle)

      raise(NoMatchingWindowFoundException, selector_string)
    end

    # return a handle to the currently active window if it is still open; otherwise nil
    def current_window
      @driver.window_handle
    rescue Selenium::WebDriver::Error::NoSuchWindowError
      nil
    end

    def matches?(handle)
      @driver.switch_to.window(handle) do
        matches_title = @selector[:title].nil? || @browser.title =~ /#{@selector[:title]}/
        matches_url = @selector[:url].nil? || @browser.url =~ /#{@selector[:url]}/

        matches_title && matches_url
      end
    rescue Selenium::WebDriver::Error::NoSuchWindowError, Selenium::WebDriver::Error::NoSuchDriverError
      # the window may disappear while we're iterating.
      false
    end

    def wait_for_exists
      return assert_exists unless Watir.relaxed_locate?

      begin
        wait_until(&:exists?)
      rescue Wait::TimeoutError
        raise NoMatchingWindowFoundException, selector_string
      end
    end
  end # Window
end # Watir
