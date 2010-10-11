# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'watir-webdriver'
require 'locator_spec_helper'
require 'rubygems'
require 'rspec'

include Watir
include Watir::Exception

WEBDRIVER_SELECTORS = [:class, :class_name, :css, :id, :name, :tag_name, :xpath]

