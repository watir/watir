# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'watir-webdriver'
require 'spec'
require 'spec/autorun'

include Watir
include Watir::Exception


if defined?(WatirSpec)
  browser = (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym

  WatirSpec.implementation do |imp|
    imp.name          = :webdriver
    imp.browser_class = Watir::Browser
    imp.browser_args  = [browser]

    imp.guard_proc = lambda { |args|
      args.any? { |arg| arg == :webdriver || arg == [:webdriver, browser] }
    }
  end
end
