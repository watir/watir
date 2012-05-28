# encoding: utf-8
module Watir
  class Alert

    include EventuallyPresent

    def initialize(target_locator)
      @target_locator = target_locator
      @alert = nil
    end

    def text
      assert_exists
      @alert.text
    end

    def ok
      assert_exists
      @alert.accept
    end

    def close
      assert_exists
      @alert.dismiss
    end

    def set(value)
      assert_exists
      @alert.send_keys(value)
    end

    def exists?
      assert_exists
      true
    rescue Exception::UnknownObjectException
      false
    end
    alias_method :present?, :exists?

    def selector_string
      'alert'
    end

    private

    def assert_exists
      @alert = @target_locator.alert
    rescue Selenium::WebDriver::Error::NoAlertPresentError
      raise Exception::UnknownObjectException, 'unable to locate alert'
    end

  end # Alert
end # Watir
