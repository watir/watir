module WatirSpec
  module SpecHelper

    module BrowserHelper
      def browser; @browser; end
    end

    module PersistentBrowserHelper
      def browser; $browser; end
    end

    module MessagesHelper
      def messages
        browser.div(:id, 'messages').divs.map { |d| d.text }
      end
    end

    module_function

    def execute
      load_requires
      start_server
      configure
      add_guard_hook
    end

    def configure
      Thread.abort_on_exception = true

      Spec::Runner.configure do |config|
        config.include(MessagesHelper)

        if WatirSpec.persistent_browser == false
          config.include(BrowserHelper)

          config.before(:all) { @browser = WatirSpec.new_browser }
          config.after(:all)  { @browser.close if @browser       }
        else
          config.include(PersistentBrowserHelper)
          $browser = WatirSpec.new_browser
          at_exit { $browser.close }
        end
      end
    end

    def load_requires
      # load spec_helper from containing folder, if it exists
      hook = File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper.rb")
      raise(Errno::ENOENT, hook) unless File.exist?(hook)

      require hook
      require "fileutils"
      require "spec"

      begin
        require "ruby-debug"
        Debugger.start
        Debugger.settings[:autoeval] = true
        Debugger.settings[:autolist] = 1
      rescue LoadError
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
