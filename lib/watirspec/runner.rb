module WatirSpec
  module Runner

    module BrowserHelper
      def browser
        $browser
      end
    end

    module MessagesHelper
      def messages
        browser.div(id: 'messages').divs.map(&:text)
      end
    end

    module_function

    def execute
      start_server
      configure
      add_guard_hook

      @executed = true
    end

    def execute_if_necessary
      execute unless @executed
    end

    def configure
      Thread.abort_on_exception = true
      return unless defined?(RSpec)

      RSpec.configure do |config|
        config.include(BrowserHelper)
        config.include(MessagesHelper)

        if WatirSpec.implementation.name == :sauce
          config.before(:each) do
            $browser = WatirSpec.new_browser
          end

          config.after(:each) do
            $browser.close
          end
        else
          $browser = WatirSpec.new_browser
          at_exit { $browser.close }
        end
      end
    end

    def start_server
      WatirSpec::Server.run!
    end

    def add_guard_hook
      return if WatirSpec.unguarded?
      at_exit { WatirSpec::Guards.report } unless ENV['USE_SAUCE']
    end

  end # SpecHelper
end # WatirSpec
