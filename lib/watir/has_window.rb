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

    def windows(*args, title: nil, url: nil, element: nil)
      selector = if args.empty?
                   {title: title, url: url, element: element}.delete_if { |_k, v| v.nil? }
                 else
                   Watir.logger.deprecate('passing in arguments or Hashes to Browser#windows',
                                          'keywords for allowed selectors instead',
                                          ids: [:window_args])
                   extract_selector(args)
                 end

      WindowCollection.new self, **selector
    end

    #
    # Returns browser window.
    #
    # @example
    #   browser.window(title: 'closeable window')
    #
    # @return [Window]
    #

    # TODO: Remove cop disable when remove args & index
    # rubocop:disable Metrics/ParameterLists
    def window(*args, index: nil, title: nil, url: nil, handle: nil, element: nil, &blk)
      selector = if args.empty?
                   {index: index,
                    title: title,
                    url: url,
                    element: element,
                    handle: handle}.delete_if { |_k, v| v.nil? }
                 else
                   Watir.logger.deprecate('passing in argument pairs to Browser#window',
                                          'keywords for allowed selectors instead',
                                          ids: [:window_args])
                   extract_selector(args)
                 end

      win = Window.new self, **selector

      win.use(&blk) if block_given?

      win
    end
    # rubocop:enable Metrics/ParameterLists

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
  end # HasWindow
end # Watir
