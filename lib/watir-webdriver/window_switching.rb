module Watir
  module WindowSwitching

    class NoMatchingWindowFoundException < StandardError
    end

    def windows(*args)
      all = @driver.window_handles.map { |handle| Window.new(@driver, :handle => handle) }

      if args.empty?
        all
      else
        filter_windows(args, all, :select)
      end
    end

    def window(*args, &blk)
      win = Window.new @driver, extract_selector(args)

      win.use(&blk) if block_given?

      win
    end

    private

    def filter_windows(args, all, method)
      sel = extract_selector(args)

      unless sel.keys.all? { |k| [:title, :url].include? k }
        raise ArgumentError, "invalid window selector: #{sel.inspect}"
      end

      all.send(method) do |win|
        sel.all? { |key, value| value === win.send(key) }
      end
    end
  end # WindowSwitching

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
        unless selector.keys.all? { |k| [:title, :url].include? k }
          raise ArgumentError, "invalid window selector: #{selector.inspect}"
        end
      end
    end

    def inspect
      '#<%s:0x%x located=%s>' % [self.class, hash*2, !!@handle]
    end

    def exists?
      handle
      true
    rescue NoMatchingWindowFoundException
      false
    end
    alias_method :present?, :exists? # for Wait::EventuallyPresent

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
      if current?
        yield if block_given?
        return self
      end

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
      handle = @driver.window_handles.find { |handle|
        matches?(handle)
      }

      handle or raise NoMatchingWindowFoundException, @selector.inspect
    end

    def matches?(handle)
      @driver.switch_to.window(handle) {
        matches_title = @selector[:title].nil? || @selector[:title] === @driver.title
        matches_url   = @selector[:url].nil? || @selector[:url] === @driver.current_url

        matches_title && matches_url
      }
    end

  end # Window
end # Watir
