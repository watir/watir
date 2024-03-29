# frozen_string_literal: true

module Watir
  module HasWindow
    attr_writer :original_window

    #
    # Returns browser windows array.
    #
    # @example
    #   browser.windows(title: 'closeable window')
    #
    # @return [Array<Window>]
    #

    def windows(opts = {})
      WindowCollection.new self, opts
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

      win.use(&blk) if blk

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
  end # HasWindow
end # Watir
