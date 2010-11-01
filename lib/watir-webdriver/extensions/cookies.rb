module Watir
  class Browser

    def clear_all_cookies
      @driver.manage.clear_cookies
    end

  end
end


module Selenium
  module WebDriver

    class Options
      def clear_cookies
        @bridge.clearCookies
      end
    end

    module Remote
      class Bridge
        def clearCookies
          execute :clearCookies
        end

        command :clearCookies, :delete, "session/:session_id/cookies"
      end
    end

     module Firefox
      class Profile
        remove_const :WEBDRIVER_EXTENSION_PATH
        WEBDRIVER_EXTENSION_PATH = File.expand_path('../firefox/webdriver.xpi', __FILE__)
      end
     end

  end
end
