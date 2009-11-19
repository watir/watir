module Watir
  class Button < HTMLElement

    #
    # custom locate since this also covers <input type="button"> elements
    # TODO: attribute methods..
    #

    def locate
      super || begin
        @selector[:tag_name] = :input
        @selector[:type]     = /button|submit|reset/
        result = ElementLocator.new(@parent.driver, @selector).locate
      rescue WebDriver::Error::WebDriverError
        nil
      end
    end

  end
end