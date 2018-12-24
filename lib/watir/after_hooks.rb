module Watir
  #
  # After hooks are blocks that run after certain browser events.
  # They are generally used to ensure application under test does not encounter
  # any error and are automatically executed after following events:
  #   1. Open URL.
  #   2. Refresh page.
  #   3. Click, double-click or right-click on element.
  #   4. Alert closing.
  #

  class AfterHooks
    include Enumerable

    def initialize(browser)
      @browser = browser
      @after_hooks = []
    end

    #
    # Adds new after hook.
    #
    # @example
    #   browser.after_hooks.add do |browser|
    #     browser.text.include?("Server Error") and puts "Application exception or 500 error!"
    #   end
    #   browser.goto "watir.com/404"
    #   "Application exception or 500 error!"
    #
    # @param [#call] after_hook Object responding to call
    # @yield after_hook block
    # @yieldparam [Watir::Browser]
    #

    def add(after_hook = nil, &block)
      if block_given?
        @after_hooks << block
      elsif after_hook.respond_to? :call
        @after_hooks << after_hook
      else
        raise ArgumentError, 'expected block or object responding to #call'
      end
    end
    alias << add

    #
    # Deletes after hook.
    #
    # @example
    #   browser.after_hooks.add do |browser|
    #     browser.text.include?("Server Error") and puts "Application exception or 500 error!"
    #   end
    #   browser.goto "watir.com/404"
    #   "Application exception or 500 error!"
    #   browser.after_hooks.delete browser.after_hooks[0]
    #   browser.refresh
    #

    def delete(after_hook)
      @after_hooks.delete(after_hook)
    end

    #
    # Runs after hooks.
    #

    def run
      # We can't just rescue exception because Firefox automatically closes alert when exception raised
      return unless @after_hooks.any? && !@browser.alert.exists?

      each { |after_hook| after_hook.call(@browser) }
    rescue Selenium::WebDriver::Error::NoSuchWindowError => ex
      Watir.logger.info "Could not execute After Hooks because browser window was closed #{ex}"
    end

    #
    # Executes a block without running error after hooks.
    #
    # @example
    #   browser.after_hooks.without do |browser|
    #     browser.element(name: "new_user_button").click
    #   end
    #
    # @yield Block that is executed without after hooks being run
    # @yieldparam [Watir::Browser]
    #

    def without
      current_after_hooks = @after_hooks
      @after_hooks = []
      yield(@browser)
    ensure
      @after_hooks = current_after_hooks
    end

    #
    # Yields each after hook.
    #
    # @yieldparam [#call] after_hook Object responding to call
    #

    def each
      @after_hooks.each { |after_hook| yield after_hook }
    end

    #
    # Returns number of after hooks.
    #
    # @example
    #   browser.after_hooks.add { puts 'Some after_hook.' }
    #   browser.after_hooks.length
    #   #=> 1
    #
    # @return [Integer]
    #

    def length
      @after_hooks.length
    end
    alias size length

    #
    # Gets the after hook at the given index.
    #
    # @param [Integer] index
    # @return [#call]
    #

    def [](index)
      @after_hooks[index]
    end
  end # AfterHooks
end # Watir
