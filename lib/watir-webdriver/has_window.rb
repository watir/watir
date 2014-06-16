module Watir
  module HasWindow

    #
    # Returns browser windows array.
    #
    # @example
    #   browser.goto "http://www.w3schools.com/html/tryit.asp?filename=tryhtml_link_target"
    #   browser.iframe(:id => "iframeResult").a.click
    #   browser.windows(:title => 'W3Schools Online Web Tutorials')
    #
    # @return [Array<Window>]
    #

    def windows(*args)
      all = @driver.window_handles.map { |handle| Window.new(@driver, :handle => handle) }

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
    #   browser.goto "http://www.w3schools.com/html/tryit.asp?filename=tryhtml_link_target"
    #   browser.iframe(:id => "iframeResult").a.click
    #   browser.window(:index => 1)
    #
    # @return [Window]
    #

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

  end # HasWindow
end # Watir
