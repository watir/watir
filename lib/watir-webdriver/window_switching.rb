module Watir
  module WindowSwitching

    def windows
      @driver.window_handles.map do |id|
        Window.new(@driver, id)
      end
    end

    def window(*args, &blk)
      sel = extract_selector(args)

      unless sel.keys.all? { |k| [:title, :url].include? k }
        raise ArgumentError, "invalid window selector: #{sel}"
      end

      win = windows.find do |win|
        sel.all? { |key, value| value === win.send(key) }
      end

      if win && block_given?
        win.use(&blk)
      end

      win
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
