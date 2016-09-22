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

      RSpec.configure do |config|
        config.include(BrowserHelper)
        config.include(MessagesHelper)

        $browser = WatirSpec.new_browser
        at_exit { $browser.close }
      end
    end

    def start_server
      if WatirSpec::Server.should_run?
        WatirSpec::Server.run_async
      else
        $stderr.puts "not running WatirSpec::Server"
      end
    end

    def add_guard_hook
      return if WatirSpec.unguarded?
      at_exit { WatirSpec::Guards.report }
    end

  end # SpecHelper
end # WatirSpec
