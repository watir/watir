module Watir
  module HasWindow
    #
    # Returns browser windows array.
    #
    # @example
    #   browser.windows(title: 'closeable window')
    #
    # @return [Array<Window>]
    #

    def windows(opts = {})
      all = @driver.window_handles.map { |handle| Window.new(self, handle: handle) }

      opts.empty? ? all : filter_windows(opts, all)
    end

    #
    # Returns browser window.
    #
    # @example
    #   browser.window(title: 'closeable window')
    #
    # @return [Window]
    #

    def window(opts = {}, &blk)
      win = Window.new self, opts

      win.use(&blk) if block_given?

      win
    end

    #
    # Returns original window if defined, current window if not
    # See Window#use
    #
    # @example
    #   browser.window(title: 'closeable window').use
    #   browser.original_window.use
    #
    # @return [Window]
    #

    def original_window
      @original_window ||= window
    end

    private

    def filter_windows(selector, windows)
      unless selector.keys.all? { |k| %i[title url].include? k }
        raise ArgumentError, "invalid window selector: #{selector.inspect}"
      end

      windows.select do |win|
        selector.all? { |key, value| win.send(key) =~ /#{value}/ }
      end
    end
  end # HasWindow
end # Watir
