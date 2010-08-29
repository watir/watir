module Watir
  module WindowSwitching

    def windows(*args)
      wins = @driver.window_handles.map do |id|
        Window.new(@driver, id)
      end

      if args.empty?
        wins
      else
        filter_windows(args, wins, :select)
      end
    end

    def window(*args, &blk)
      win = filter_windows(args, windows, :find)

      if win && block_given?
        win.use(&blk)
      end

      win
    end

    private

    def filter_windows(args, wins, method)
      sel = extract_selector(args)

      unless sel.keys.all? { |k| [:title, :url].include? k }
        raise ArgumentError, "invalid window selector: #{sel}"
      end

      wins.send(method) do |win|
        sel.all? { |key, value| value === win.send(key) }
      end
    end
  end # WindowSwitching

  class Window
    def initialize(driver, id)
      @driver, @id = driver, id
    end


    def inspect
      '#<%s:0x%x id=%s>' % [self.class, hash*2, @id.to_s]
    end

    def current?
      @driver.window_handle == @id
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
      @driver.switch_to.window(@id, &blk)
      self
    end
  end # Window
end # Watir
