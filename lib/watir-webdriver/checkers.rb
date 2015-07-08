module Watir

  #
  # Checkers are blocks that run after certain browser events.
  # They are generally used to ensure application under test does not encounter
  # any error and are automatically executed after following events:
  #   1. Open URL.
  #   2. Refresh page.
  #   3. Click, double-click or right-click on element.
  #   4. Alert closing.
  #

  class Checkers
    include Enumerable

    def initialize(browser)
      @browser = browser
      @checkers = []
    end

    #
    # Adds new checker.
    #
    # @example
    #   browser.checkers.add do |browser|
    #     browser.text.include?("Server Error") and puts "Application exception or 500 error!"
    #   end
    #   browser.goto "www.watir.com/404"
    #   "Application exception or 500 error!"
    #
    # @param [#call] checker Object responding to call
    # @yield Checker block
    # @yieldparam [Watir::Browser]
    #

    def add(checker = nil, &block)
      if block_given?
        @checkers << block
      elsif checker.respond_to? :call
        @checkers << checker
      else
        raise ArgumentError, "expected block or object responding to #call"
      end
    end
    alias_method :<<, :add

    #
    # Deletes checker.
    #
    # @example
    #   browser.checkers.add do |browser|
    #     browser.text.include?("Server Error") and puts "Application exception or 500 error!"
    #   end
    #   browser.goto "www.watir.com/404"
    #   "Application exception or 500 error!"
    #   browser.checkers.delete browser.checkers[0]
    #   browser.refresh
    #

    def delete(checker)
      @checkers.delete(checker)
    end

    #
    # Runs checkers.
    #

    def run
      if @checkers.any? && @browser.window.present?
        each { |checker| checker.call(@browser) }
      end
    end

    #
    # Executes a block without running error checkers.
    #
    # @example
    #   browser.checkers.without do |browser|
    #     browser.element(name: "new_user_button").click
    #   end
    #
    # @yield Block that is executed without checkers being run
    # @yieldparam [Watir::Browser]
    #

    def without
      current_checkers = @checkers
      @checkers = []
      yield(@browser)
    ensure
      @checkers = current_checkers
    end

    #
    # Yields each checker.
    #
    # @yieldparam [#call] checker Object responding to call
    #

    def each
      @checkers.each { |checker| yield checker }
    end

    #
    # Returns number of checkers.
    #
    # @example
    #   browser.checkers.add { puts 'Some checker.' }
    #   browser.checkers.length
    #   #=> 1
    #
    # @return [Fixnum]
    #

    def length
      @checkers.length
    end
    alias_method :size, :length

    #
    # Get the checker at the given index.
    #
    # @param [Fixnum] index
    # @return [#call]
    #

    def [](index)
      @checkers[index]
    end

  end # Checkers
end # Watir
