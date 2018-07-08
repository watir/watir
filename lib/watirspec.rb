require "tmpdir"
require 'watirspec/guards'
require 'watirspec/implementation'
require 'watirspec/runner'
require 'watirspec/server'

module WatirSpec
  class << self
    attr_accessor :browser_args, :unguarded, :implementation

    def htmls
      @htmls ||= [File.expand_path("../../spec/watirspec/html", __FILE__)]
    end

    def run!
      load_support
      WatirSpec::Runner.execute_if_necessary
    end

    def url_for(str)
      File.join(host, str)
    end

    def host
      @host ||= "http://#{Server.bind}:#{Server.port}"
    end

    def unguarded?
      @unguarded ||= false
    end

    def load_support
      root = File.expand_path("../../spec/watirspec", __FILE__)
      Dir.glob("#{root}/support/**/*.rb").each do |file|
        require file
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

    private

    def print_browser_info_once(instance)
      return if defined?(@did_print_browser_info) && @did_print_browser_info
      @did_print_browser_info = true

      info = []
      info << instance.class.name

      caps = instance.driver.capabilities

      info << "#{caps.browser_name}"
      info << "#{caps.version}"

      Watir.logger.warn "running watirspec against #{info.join ' '} using:\n#{WatirSpec.implementation.inspect_args}",
                        ids: [:browser_info]
    rescue
      # ignored
    end

  end # class << WatirSpec
end # WatirSpec
