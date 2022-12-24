# frozen_string_literal: true

module WatirSpec
  class RemoteServer
    include Watir::Exception

    attr_reader :server

    def start(port = 4444, args: [])
      require 'selenium/server'

      @server ||= Selenium::Server.new(jar,
                                       port: Selenium::WebDriver::PortProber.above(port),
                                       log: !!$DEBUG,
                                       background: true,
                                       timeout: 60)
      args.each { |arg| @server << arg }
      @server.start
      at_exit { @server.stop }
    end

    private

    def jar
      if File.exist?(ENV['REMOTE_SERVER_BINARY'] || '')
        ENV.fetch('REMOTE_SERVER_BINARY', nil)
      elsif ENV['LOCAL_SELENIUM']
        File.expand_path('../selenium/bazel-bin/java/server/src/org/openqa/selenium/grid/selenium_server_deploy.jar')
      elsif !Dir.glob('*selenium*.jar').empty?
        Dir.glob('*selenium*.jar').first
      else
        Selenium::Server.download
      end
    rescue SocketError
      # not connected to internet
      raise Error, 'unable to find or download selenium-server jar'
    end
  end
end
