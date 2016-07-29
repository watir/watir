# TODO - remove this when implemented in Selenium
module Selenium
  module WebDriver
    module Support
      class EventFiringBridge

        def accept_alert
          dispatch(:accept_alert, driver) do
            @delegate.acceptAlert
          end
        end
        alias_method :acceptAlert, :accept_alert

        def dismiss_alert
          dispatch(:dismiss_alert, driver) do
            @delegate.dismissAlert
          end
        end
        alias_method :dismissAlert, :dismiss_alert

        def double_click
          dispatch(:double_click, driver) do
            @delegate.doubleClick
          end
        end
        alias_method :doubleClick, :double_click

        def context_click
          dispatch(:context_click, driver) do
            @delegate.contextClick
          end
        end
        alias_method :right_click, :context_click
        alias_method :contextClick, :context_click

        def submit_element(id)
          dispatch(:submit_element, driver) do
            @delegate.submitElement(id)
          end
        end
        alias_method :submitElement, :submit_element

        def refresh
          dispatch(:refresh, driver) do
            @delegate.refresh
          end
        end

      end
    end
  end
end

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

  class AfterHooks < Selenium::WebDriver::Support::AbstractEventListener
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
    #   browser.goto "watir.github.io/404"
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
        raise ArgumentError, "expected block or object responding to #call"
      end
    end
    alias_method :<<, :add

    #
    # Deletes after hook.
    #
    # @example
    #   browser.after_hooks.add do |browser|
    #     browser.text.include?("Server Error") and puts "Application exception or 500 error!"
    #   end
    #   browser.goto "watir.github.io/404"
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

    %w[navigate_to click context_click accept_alert dismiss_alert double_click right_click
       submit_element refresh].each do |method|
      define_method("after_#{method}") do |*args|
        if @after_hooks.any? && @browser.window.present?
          each { |after_hook| after_hook.call(@browser) }
        end
      end
      # TODO - remove this when implemented in Selenium
      define_method("before_#{method}") do |*args|
        # Do nothing
      end
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
    # @return [Fixnum]
    #

    def length
      @after_hooks.length
    end
    alias_method :size, :length

    #
    # Gets the after hook at the given index.
    #
    # @param [Fixnum] index
    # @return [#call]
    #

    def [](index)
      @after_hooks[index]
    end

  end # AfterHooks
end # Watir
