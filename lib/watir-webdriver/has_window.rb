module Watir
  module HasWindow
    def windows(*args)
      all = @driver.window_handles.map { |handle| Window.new(@driver, :handle => handle) }

      if args.empty?
        all
      else
        filter_windows extract_selector(args), all
      end
    end

    def window(*args, &blk)
      win = Window.new @driver, extract_selector(args)

      win.use(&blk) if block_given?

      win
    end

    private

    def filter_windows(selector, windows)
      unless selector.keys.all? { |k| [:title, :url].include? k }
        raise ArgumentError, "invalid window selector: #{selector.inspect}"
      end

      windows.select do |win|
        selector.all? { |key, value| value === win.send(key) }
      end
    end
  end # WindowSwitching
end # Watir
