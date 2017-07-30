module Watir
  class Alert
    include EventuallyPresent
    include Waitable

    attr_reader :browser

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
      Watir.executor.go(self) { @alert.text }
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
      Watir.executor.go(self) { @alert.accept }
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
      Watir.executor.go(self) { @alert.dismiss }
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
      Watir.executor.go(self) { @alert.send_keys(value) }
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

    def unknown_exception
      Watir::Exception::UnknownObjectException
    end

  end # Alert
end # Watir
