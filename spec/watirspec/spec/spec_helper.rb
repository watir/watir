module WatirSpec
  module SpecHelper

    module_function

    def execute
      configure
      load_requires
      start_server
    end

    def configure
      Thread.abort_on_exception = true
    end

    def load_requires
      require "fileutils"
      require "#{File.dirname(__FILE__)}/../watirspec"

      hook = File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper.rb")
      raise(Errno::ENOENT, hook) unless File.exist?(hook)
      require hook

      require "spec"
    end
    
    def start_server
      if WatirSpec::Server.should_run?
        Thread.new { WatirSpec::Server.run! }
        sleep 0.1 until WatirSpec::Server.running?
      else
        $stderr.puts "not running WatirSpec::Server"
      end
    end

  end # SpecHelper
end # WatirSpec


WatirSpec::SpecHelper.execute

