# frozen_string_literal: true

module Watir
  class Window
    include Waitable
    include Exception

    attr_reader :browser

    def initialize(browser, selector = {})
      @browser = browser
      @driver = browser.driver
      @selector = selector

      if selector.empty?
        @handle = current_window
      elsif selector.key? :handle
        @handle = selector.delete :handle
      else
        types = %i[title url element]
        return if selector.keys.all? { |k| types.include? k }

        raise ArgumentError, "invalid window selector: #{selector_string}"
      end
    end

    def inspect
      format('#<%<class>s:0x%<hash>x located=%<handle>s>',
             class: self.class, hash: hash * 2, handle: !!@handle)
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
    # Minimize window.
    #
    # @example
    #   browser.window.minimize
    #

    def minimize
      use { @driver.manage.window.minimize }
    end

    #
    # Make window full screen.
    #
    # @example
    #   browser.window.full_screen
    #

    def full_screen
      use { @driver.manage.window.full_screen }
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
    #   browser.window(title: /window_switching/) == browser.window(/closeable/)
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
      [handle, self.class].hash
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

    def use
      wait_for_exists
      cache_current = current_window
      @browser.original_window ||= cache_current
      restore_to = unless cache_current == handle
                     @driver.switch_to.window(handle)
                     cache_current
                   end
      if block_given?
        begin
          yield
        ensure
          @driver.switch_to.window(restore_to) if restore_to
        end
      end
      self
    end

    #
    # @api private
    #

    def selector_string
      @selector.inspect
    end

    def handle
      @handle ||= locate
    end

    private

    def locate
      @selector.empty? ? nil : @driver.window_handles.find { |wh| matches?(wh) }
    end

    def assert_exists
      return if !handle.nil? && @driver.window_handles.include?(handle)

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
        matches_element = @selector[:element].nil? || @selector[:element].exists?

        matches_title && matches_url && matches_element
      end
    rescue Selenium::WebDriver::Error::NoSuchWindowError
      # the window may disappear while we're iterating.
      false
    end

    def wait_for_exists
      wait_until(&:exists?)
    rescue Wait::TimeoutError
      raise NoMatchingWindowFoundException, selector_string
    end
  end # Window
end # Watir
