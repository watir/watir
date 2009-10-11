module WatirSpec
  class << self
    attr_accessor :browser_args, :persistent_browser, :ungarded

    def html
      File.expand_path("#{File.dirname(__FILE__)}/../html")
    end

    def files
      "file://#{html}"
    end

    def host
      "http://#{Server.host}:#{Server.port}"
    end

    def ungarded?
      @ungarded ||= false
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
      @implementation ||= case Browser.name
                          when "Watir::IE"
                            :watir
                          when "Watir::Firefox", "FireWatir::Firefox"
                            :firewatir
                          when "Celerity::Browser"
                            :celerity
                          else
                            :unknown
                          end
    end

    def new_browser
      args = WatirSpec.browser_args
      args ? Browser.new(*args) : Browser.new
    end

    def ruby
      if @ruby.nil?
        if defined?(Gem)
          @ruby = Gem.ruby
        else
          require "rbconfig"
          rb = File.join(RbConfig::CONFIG.values_at('BINDIR', 'RUBY_INSTALL_NAME').compact)
          ext = RbConfig::CONFIG['EXEEXT']

          @ruby = "#{rb}#{ext}"
        end
      end

      @ruby
    end

  end # class << WatirSpec
end # WatirSpec
