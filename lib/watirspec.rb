require "tmpdir"
require 'watirspec/guards'
require 'watirspec/implementation'
require 'watirspec/runner'
require 'watirspec/server'

module WatirSpec
  class << self
    attr_accessor :browser_args, :unguarded, :implementation

    def html
      @html ||= File.expand_path("../../spec/watirspec/html", __FILE__)
    end

    def run!
      WatirSpec::Runner.execute_if_necessary
    end

    def url_for(str, opts = {})
      File.join(host, str)
    end

    def host
      @host ||= "http://#{Server.bind}:#{Server.port}"
    end

    def unguarded?
      @unguarded ||= false
    end

    def platform
      @platform ||= case RUBY_PLATFORM
                    when /java/
                      :java
                    when /mswin|msys|mingw32/
                      :windows
                    when /darwin/
                      :macosx
                    when /linux/
                      :linux
                    else
                      RUBY_PLATFORM
                    end
    end

    def implementation
      @implementation ||= (
        imp = WatirSpec::Implementation.new
        yield imp if block_given?

        imp
      )
    end

    def implementation=(imp)
      unless imp.is_a?(WatirSpec::Implementation)
        raise TypeError, "expected WatirSpec::Implementation, got #{imp.class}"
      end

      @implementation = imp
    end

    def new_browser
      klass = WatirSpec.implementation.browser_class
      args = Array(WatirSpec.implementation.browser_args).map { |e| Hash === e ? e.dup : e }

      instance = klass.new(*args)
      print_browser_info_once(instance)

      instance
    end

    def ruby
      @ruby ||= (
        if defined?(Gem)
          Gem.ruby
        else
          require "rbconfig"
          rb = File.join(RbConfig::CONFIG.values_at('BINDIR', 'RUBY_INSTALL_NAME').compact)
          ext = RbConfig::CONFIG['EXEEXT']

          "#{rb}#{ext}"
        end
      )
    end

    private

    def print_browser_info_once(instance)
      return if defined?(@did_print_browser_info) && @did_print_browser_info
      @did_print_browser_info = true

      info = []
      info << instance.class.name

      if instance.respond_to?(:driver) && instance.driver.class.name == "Selenium::WebDriver::Driver"
        info << "(webdriver)"
        caps = instance.driver.capabilities

        info << "#{caps.browser_name}"
        info << "#{caps.version}"
      end

      $stderr.puts "running watirspec against #{info.join ' '} using args #{WatirSpec.implementation.browser_args.inspect}"
    rescue
      # ignored
    end

  end # class << WatirSpec
end # WatirSpec
