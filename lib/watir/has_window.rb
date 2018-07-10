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

    def windows(*args)
      all = @driver.window_handles.map { |handle| Window.new(self, handle: handle) }

      if args.empty?
        all
      else
        filter_windows extract_selector(args), all
      end
    end

    #
    # Returns browser window.
    #
    # @example
    #   browser.window(title: 'closeable window')
    #
    # @return [Window]
    #

    def window(*args, &blk)
      win = Window.new self, extract_selector(args)

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

    #
    # Waits for and returns second window if present
    # See Window#use
    #
    # @example
    #   browser.switch_window
    #
    # @return [Window]
    #

    def switch_window
      current_window = window
      wins = windows
      wait_until { (wins = windows) && wins.size > 1 } if wins.size == 1
      raise StandardError, 'Unable to determine which window to switch to' if wins.size > 2

      wins.find { |w| w != current_window }.use
      window
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
