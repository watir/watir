require "fileutils"

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

if RUBY_PLATFORM =~ /java/
  if ENV['CELERITY_JAR'] == '1'
    require Dir["pkg/celerity-complete-*.jar"].first
    require "celerity"
  else
    $:.unshift File.expand_path("#{File.dirname(__FILE__)}/../lib")
    require 'celerity'
  end

  include Celerity
  include Celerity::Exception
  java.lang.System.setProperty("java.awt.headless", "true")
else
  puts "Not using JRuby - trying to run specs on Watir…"
  require 'watir'
  include Watir
  include Watir::Exception
end

Thread.abort_on_exception = true
HTML_DIR = "file://#{File.expand_path(File.dirname(__FILE__))}/html"
BROWSER_OPTIONS = {
  :log_level => $DEBUG ? :all : :off,
  # :browser   => :internet_explorer
}

BROWSER_OPTIONS.freeze

# ===========
# = WEBrick =
# ===========

if RUBY_PLATFORM =~ /java/ || ENV['WATIR_SPEC']
  unless defined? WEBRICK_SERVER
    require File.dirname(__FILE__) + "/../support/spec_server"
    s = Celerity::SpecServer.new
    begin
      s.run
    rescue Errno::EADDRINUSE => e
      p :error => e
    end
    TEST_HOST = s.host
  end
else
  puts "Remember to run \"rake specserver\" before running these tests!"
  TEST_HOST = "http://localhost:2000"
end

