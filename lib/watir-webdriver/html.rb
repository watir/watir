require "nokogiri"
require "open-uri"
require "pp"
require "webidl"
require "active_support/inflector"

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'body', 'bodys'
  inflect.irregular 'tbody', 'tbodys'
  inflect.irregular 'canvas', 'canvases'
  inflect.irregular 'ins', 'inses'
end

require "watir-webdriver/html/util"
require "watir-webdriver/html/visitor"
require "watir-webdriver/html/idl_sorter"
require "watir-webdriver/html/spec_extractor"
require "watir-webdriver/html/generator"