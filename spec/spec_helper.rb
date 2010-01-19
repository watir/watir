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

  WatirSpec.browser_args   = [browser]
  WatirSpec.implementation = :webdriver
end
