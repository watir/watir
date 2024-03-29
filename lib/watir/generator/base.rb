# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'webidl'
require 'active_support/inflector'

require 'watir/generator/base/generator'
require 'watir/generator/base/idl_sorter'
require 'watir/generator/base/spec_extractor'
require 'watir/generator/base/util'
require 'watir/generator/base/visitor'
