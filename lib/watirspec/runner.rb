# frozen_string_literal: true

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

      def event_log
        browser.div(id: 'log').wait_until(&:present?).ps.map(&:text)
      end
    end

    module_function

    @execute = true

    def execute=(bool)
      @execute = bool
    end

    def execute
      start_server unless ENV['WATIR_PUBLIC_SERVER']
      configure
      add_guard_hook

      @executed = true
    end

    def execute_if_necessary
      execute if (!defined?(@executed) || !@executed) && @execute
    end

    def configure
      Thread.abort_on_exception = true
      return unless defined?(RSpec)

      RSpec.configure do |config|
        config.include(BrowserHelper)
        config.include(MessagesHelper)

        config.before(:suite) { $browser = WatirSpec.new_browser }
        config.after(:suite) { $browser&.close }
      end
    end

    def start_server
      WatirSpec::Server.run!
    end

    def add_guard_hook
      return if WatirSpec.unguarded?

      at_exit { WatirSpec::Guards.report }
    end
  end # Runner
end # WatirSpec
