module Watir
  class Window
    include EventuallyPresent

    def initialize(driver, selector)
      @driver   = driver
      @selector = selector

      if selector.empty?
        @handle = driver.window_handle
      elsif selector.has_key? :handle
        @handle = selector.delete :handle
      else
        unless selector.keys.all? { |k| [:title, :url, :index].include? k }
          raise ArgumentError, "invalid window selector: #{selector.inspect}"
        end
      end
    end

    def inspect
      '#<%s:0x%x located=%s>' % [self.class, hash*2, !!@handle]
    end

    #
    # Returns window size.
    #
    # @example
    #   size = browser.window.size
    #   "%sx%s" % [size.width, size.height]
    #   #=> "1600x1200"
    #

    def size
      size = nil
      use { size = @driver.manage.window.size }

      size
    end

    #
    # Returns window position.
    #
    # @example
    #   position = browser.window.position
    #   "%sx%s" % [position.x, position.y]
    #   #=> "92x76"
    #

    def position
      pos = nil
      use { pos = @driver.manage.window.position }

      pos
    end

    #
    # Resizes window to given width and height.
    #
    # @example
    #   browser.window.resize_to 1600, 1200
    #
    # @param [Fixnum] width
    # @param [Fixnum] height
    #

    def resize_to(width, height)
      dimension = Selenium::WebDriver::Dimension.new(width, height)
      use { @driver.manage.window.size = dimension }

      dimension
    end

    #
    # Moves window to given x and y coordinates.
    #
    # @example
    #   browser.window.move_to 300, 200
    #
    # @param [Fixnum] x
    # @param [Fixnum] y
    #

    def move_to(x, y)
      point = Selenium::WebDriver::Point.new(x, y)
      use { @driver.manage.window.position = point }

      point
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
      handle
      true
    rescue Exception::NoMatchingWindowFoundException
      false
    end

    #
    # Returns true if window is present.
    #
    # @return [Boolean]
    #

    def present?
      @handle = nil # relocate

      exists?
    end

    #
    # Returns true if two windows are equal.
    #
    # @example
    #   browser.window(:index => 1) == browser.window(:index => 2)
    #
    # @param [Window] other
    #

    def ==(other)
      return false unless other.kind_of?(self.class)

      handle == other.handle
    end
    alias_method :eql?, :==

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
      @driver.window_handle == handle
    end

    #
    # CLoses window.
    #

    def close
      use { @driver.close }
    end

    #
    # Returns window title.
    #
    # @return [String]
    #

    def title
      title = nil
      use { title = @driver.title }

      title
    end

    #
    # Returns window URL.
    #
    # @return [String]
    #

    def url
      url = nil
      use { url = @driver.current_url }

      url
    end

    #
    # Switches to given window and executes block, then switches back.
    #
    # @example
    #   browser.window(:title => "2nd window").use do
    #     browser.button(:id => "close").click
    #   end
    #

    def use(&blk)
      @driver.switch_to.window(handle, &blk)
      self
    end

    protected

    def handle
      @handle ||= locate
    end

    private

    def selector_string
      @selector.inspect
    end

    def locate
      handle = if @selector.has_key?(:index)
                  @driver.window_handles[Integer(@selector[:index])]
                else
                  @driver.window_handles.find { |wh| matches?(wh) }
                end

      handle or raise Exception::NoMatchingWindowFoundException, @selector.inspect
    end

    def matches?(handle)
      @driver.switch_to.window(handle) {
        matches_title = @selector[:title].nil? || @selector[:title] === @driver.title
        matches_url   = @selector[:url].nil? || @selector[:url] === @driver.current_url

        matches_title && matches_url
      }
    rescue Selenium::WebDriver::Error::NoSuchWindowError, Selenium::WebDriver::Error::NoSuchDriverError
      # the window may disappear while we're iterating.
      false
    end

  end # Window
end # Watir
