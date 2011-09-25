# encoding: utf-8

# see http://redmine.ruby-lang.org/issues/5218
if defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby" && RUBY_VERSION >= "1.9"
  module Kernel
    alias :__at_exit :at_exit
    def at_exit(&block)
      __at_exit do
        exit_status = $!.status if $!.is_a?(SystemExit)
        block.call
        exit exit_status if exit_status
      end
    end
  end
end

module WatirSpec
  class << self
    attr_accessor :browser_args, :persistent_browser, :unguarded, :implementation

    def html
      File.expand_path("#{File.dirname(__FILE__)}/../html")
    end

    def files
      "file://#{html}"
    end

    def host
      "http://#{Server.bind}:#{Server.port}"
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
      unless imp.kind_of? WatirSpec::Implementation
        raise TypeError, "expected WatirSpec::Implementation, got #{imp.class}"
      end

      @implementation = imp
    end

    def new_browser
      klass = WatirSpec.implementation.browser_class
      args = WatirSpec.implementation.browser_args
      args ? klass.new(*args) : klass.new
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

  end # class << WatirSpec
end # WatirSpec
