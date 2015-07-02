module Watir
  class Checkers

    def initialize(browser)
      @browser = browser
      @error_checkers = []
    end

    #
    # Adds new checker.
    #
    # Checkers are generally used to ensure application under test does not encounter
    # any error. They are automatically executed after following events:
    #   1. Open URL.
    #   2. Refresh page.
    #   3. Click, double-click or right-click on element.
    #
    # @example
    #   browser.checkers.add do |page|
    #     page.text.include?("Server Error") and puts "Application exception or 500 error!"
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
        @error_checkers << block
      elsif checker.respond_to? :call
        @error_checkers << checker
      else
        raise ArgumentError, "expected block or object responding to #call"
      end
    end

    #
    # Deletes checker.
    #
    # @example
    #   checker = lambda do |page|
    #     page.text.include?("Server Error") and puts "Application exception or 500 error!"
    #   end
    #   browser.checkers.add checker
    #   browser.goto "www.watir.com/404"
    #   "Application exception or 500 error!"
    #   browser.disable_checker checker
    #   browser.refresh
    #

    def disable(checker)
      @error_checkers.delete(checker)
    end

    #
    # Runs checkers.
    #

    def run
      if @error_checkers.any? && @browser.window.present?
        @error_checkers.each { |e| e.call(@browser) }
      end
    end

    #
    # Executes a block without running error checkers.
    #
    # @example
    #   browser.checkers.without do
    #     browser.element(name: "new_user_button").click
    #   end
    #
    # @yieldparam [Watir::Browser]
    #

    def without
      current_checkers = @error_checkers
      @error_checkers = []
      yield(@browser)
    ensure
      @error_checkers = current_checkers
    end

  end # Checkers
end # Watir
