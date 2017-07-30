require 'yaml'

module Watir
  class Executor

    DOM_CHANGES = %i(click double_click right_click submit ok close goto refresh)

    def initialize
      @strategies = {element: element_strategies,
                     alert: alert_strategies,
                     window: window_strategies}

      @actions = Hash.new(->(*) {})

      DOM_CHANGES.each do |act|
        @actions["after_#{act}".to_sym] = ->(obj) { obj.browser.after_hooks.run }
      end

      allowed_strategies.each do |act|
        next if act == :none
        @actions["retry_#{act}".to_sym] = ->(ex) do
          return false unless element_errors.include?(ex.class)
          Wait.timer.remaining_time > 0
        end
      end

      @actions[:retry_global] = ->(ex) { ex.is_a? Selenium::WebDriver::Error::StaleElementReferenceError }
    end

    def go obj
      already_locked = Wait.timer.locked?

      # TODO - implement dynamic timeout
      timeout = Watir.default_timeout

      Wait.timer = Wait::Timer.new(timeout: timeout) unless already_locked

      caller = caller_locations(1, 1).first.label.to_sym
      wait_strategy = case obj
                      when Alert
                        @strategies[:alert][caller]
                      when Element
                        @strategies[:element][caller]
                      when Window
                        @strategies[:window][caller]
                      end

      begin
        self.send "wait_for_#{wait_strategy}", obj, timeout

        result = yield
        @actions["after_#{caller}".to_sym].call(obj)
        result
      rescue => ex
        retry if @actions[:retry_global].call(ex)
        retry if @actions["retry_#{wait_strategy}".to_sym].call(ex)
        raise_exception(ex, obj, timeout)
      ensure
        Wait.timer.reset! unless already_locked
      end
    end

    def raise_exception(ex, obj, timeout)
      case ex
      when Selenium::WebDriver::Error::ElementNotVisibleError, interact_error
        error = obj.send :unknown_exception
        message = "element located, but timed out after #{timeout} seconds, waiting for #{obj.inspect} to be present"
      when Selenium::WebDriver::Error::InvalidElementStateError
        error = ObjectDisabledException
        message = "element present and enabled, but timed out after #{timeout} seconds, waiting for #{obj.inspect} to not be disabled"
      when Selenium::WebDriver::Error::NoSuchWindowError
        error = Exception::NoMatchingWindowFoundException
        message = "browser window was closed"
      else
        raise
      end
      raise error, message
    end

    def element_errors
      [Selenium::WebDriver::Error::ElementNotVisibleError,
       interact_error,
       Selenium::WebDriver::Error::InvalidElementStateError].freeze
    end

    # Support for Selenium < 3.4.1 with latest Geckodriver
    def interact_error
      if defined?(Selenium::WebDriver::Error::ElementNotInteractable)
        Selenium::WebDriver::Error::ElementNotInteractable
      else
        Selenium::WebDriver::Error::ElementNotInteractableError
      end
    end

    def wait_for_exists(obj, timeout)
      return if obj.exists? # Performance shortcut

      begin
        wait_for_exists(obj.query_scope, timeout) if obj.respond_to? :query_scope
        obj.wait_until(&:exists?)
      rescue Watir::Wait::TimeoutError
        msg = "timed out after #{timeout} seconds, waiting for #{obj.inspect} to be located"
        raise obj.send(:unknown_exception), msg
      end
    end

    def wait_for_present(obj, timeout)
      return if obj.present? # Performance shortcut

      begin
        wait_for_present(obj.query_scope, timeout)
        obj.wait_until(&:present?)
      rescue Watir::Wait::TimeoutError
        msg = "element located, but timed out after #{timeout} seconds, waiting for #{obj.inspect} to be present"
        raise obj.send :unknown_exception, msg
      end
    end

    def wait_for_enabled(obj, timeout)
      wait_for_exists(obj, timeout)

      case obj
      when Input, Button, Select, Option
        # noop
      else
        return
      end

      begin
        obj.wait_until(&:enabled?)
      rescue Watir::Wait::TimeoutError
        message = "element present, but timed out after #{timeout} seconds, waiting for #{obj.inspect} to be enabled"
        raise Exception::ObjectDisabledException, message
      end
    end

    def wait_for_none(obj, _timeout)
      obj.send :assert_exists
    end

    def wait_for_writable(obj, timeout)
      wait_for_enabled(obj, timeout)

      begin
        obj.wait_until { |obj| !obj.respond_to?(:readonly?) || !obj.readonly? }
      rescue Watir::Wait::TimeoutError
        message = "element present and enabled, but timed out after #{timeout} seconds, waiting for #{obj.inspect} to not be readonly"
        raise Exception::ObjectReadOnlyException, message
      end
    end

    def allowed_strategies
      @allowed_strategies ||= %i(none exists writable enabled present)
    end

    def alert_strategies
      @alert_strategies ||= {text: :exists,
                             ok: :exists,
                             close: :exists,
                             set: :exists}
    end

    def element_strategies
      @element_strategies ||={click: :enabled,
                              set: :writable,
                              clear: :writable,
                              set?: :exists, #change to none?
                              text: :exists,
                              tag_name: :exists,
                              double_click: :present,
                              right_click: :present,
                              hover: :present,
                              drag_and_drop_on: :present,
                              drag_and_drop_by: :present,
                              attribute_value: :exists,
                              outer_html: :exists,
                              inner_html: :exists,
                              send_keys: :writable,
                              focus: :exists,
                              focused?: :exists, #change to none?,
                              fire_event: :exists,
                              visible?: :none,
                              enabled?: :none,
                              style: :exists,
                              'value=': :exists,
                              submit: :present,
                              width: :exists,
                              selected?: :exists, #change to none?
                              selected_options: :exists,
                              select_text: :exists,
                              html: :none}
    end

    def window_strategies
      @window_strategies ||= {use: :exists}
    end

    def no_waits!
      @strategies = {element: Hash.new(:none),
                     alert: Hash.new(:none),
                     window: Hash.new(:none)}
    end
  end # Executor
end # Watir
