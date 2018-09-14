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
      if ENV['LOCAL_SELENIUM']
        local = File.expand_path('../selenium/buck-out/gen/java/server/src/org/openqa/grid/selenium/selenium.jar')
      end

      if File.exist?(ENV['REMOTE_SERVER_BINARY'] || '')
        ENV['REMOTE_SERVER_BINARY']
      elsif ENV['LOCAL_SELENIUM'] && File.exist?(local)
        local
      elsif !Dir.glob('*selenium*.jar').empty?
        Dir.glob('*selenium*.jar').first
      else
        Selenium::Server.download :latest
      end
    rescue SocketError
      # not connected to internet
      raise Error, 'unable to find or download selenium-server-standalone jar'
    end
  end
end
