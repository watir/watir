module Watir
  class Alert

    include EventuallyPresent

    def initialize(browser)
      @browser = browser
      @alert = nil
    end

    #
    # Returns text of alert.
    #
    # @example
    #   browser.alert.text
    #   #=> "ok"
    #
    # @return [String]
    #

    def text
      wait_for_exists
      @alert.text
    end

    #
    # Closes alert or accepts prompts/confirms.
    #
    # @example
    #   browser.alert.ok
    #   browser.alert.exists?
    #   #=> false
    #

    def ok
      wait_for_exists
      @alert.accept
      @browser.after_hooks.run
    end

    #
    # Closes alert or cancels prompts/confirms.
    #
    # @example
    #   browser.alert.close
    #   browser.alert.exists?
    #   #=> false
    #

    def close
      wait_for_exists
      @alert.dismiss
      @browser.after_hooks.run
    end

    #
    # Enters text to prompt.
    #
    # @example
    #   browser.alert.set "Text for prompt"
    #   browser.alert.ok
    #
    # @param [String] value
    #

    def set(value)
      wait_for_exists
      @alert.send_keys(value)
    end

    #
    # Returns true if alert, confirm or prompt is present and false otherwise.
    #
    # @example
    #   browser.alert.exists?
    #   #=> true
    #

    def exists?
      assert_exists
      true
    rescue Exception::UnknownObjectException
      false
    end
    alias_method :present?, :exists?

    #
    # @api private
    #

    def selector_string
      'alert'
    end

    private

    def assert_exists
      @alert = @browser.driver.switch_to.alert
    rescue Selenium::WebDriver::Error::NoAlertPresentError
      raise Exception::UnknownObjectException, 'unable to locate alert'
    end

    def wait_for_exists
      begin
        Watir::Wait.until { exists? }
      rescue Watir::Wait::TimeoutError
        unless Watir.default_timeout == 0
          warn "This test has slept for the duration of the default timeout. "\
                "If your test is passing, consider using Alert#exists? instead of rescuing this error)"
        end
        raise Exception::UnknownObjectException, 'unable to locate alert'
      end
    end

  end # Alert
end # Watir
