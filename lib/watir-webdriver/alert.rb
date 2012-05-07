# encoding: utf-8
module Watir
  class Alert

    include EventuallyPresent

    def initialize(driver)
      @driver = driver
      @modal = nil
    end

    def text
      assert_exists
      @modal.text
    end

    def close
      assert_exists
      @modal.dismiss
    end

    def exists?
      assert_exists
      true
    rescue UnknownObjectException
      false
    end
    alias_method :present?, :exists?

    def selector_string
      'modal dialog'
    end

    private

    def assert_exists
      @modal = @driver.switch_to.alert
    rescue Selenium::WebDriver::Error::NoAlertPresentError
      raise UnknownObjectException, 'unable to locate modal dialog'
    end

  end # Alert


  class Confirm < Alert

    def accept
      assert_exists
      @modal.accept
    end

    def dismiss
      close
    end

  end # Confirm


  class Prompt < Confirm

    def set(value)
      assert_exists
      @modal.send_keys(value)
    end

  end # Prompt
end # Watir
