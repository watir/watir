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

    def size
      size = nil
      use { size = @driver.manage.window.size }

      size
    end

    def position
      pos = nil
      use { pos = @driver.manage.window.position }

      pos
    end

    def resize_to(width, height)
      dimension = Selenium::WebDriver::Dimension.new(width, height)
      use { @driver.manage.window.size = dimension }

      dimension
    end

    def move_to(x, y)
      point = Selenium::WebDriver::Point.new(x, y)
      use { @driver.manage.window.position = point }

      point
    end

    def maximize
      use { @driver.manage.window.maximize }
    end

    def exists?
      handle
      true
    rescue Exception::NoMatchingWindowFoundException
      false
    end

    def present?
      @handle = nil # relocate

      exists?
    end

    def ==(other)
      return false unless other.kind_of?(self.class)

      handle == other.handle
    end
    alias_method :eql?, :==

    def hash
      handle.hash ^ self.class.hash
    end

    def current?
      @driver.window_handle == handle
    end

    def close
      use { @driver.close }
    end

    def title
      title = nil
      use { title = @driver.title }

      title
    end

    def url
      url = nil
      use { url = @driver.current_url }

      url
    end

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
