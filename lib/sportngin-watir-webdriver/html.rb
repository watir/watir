require "nokogiri"
require "open-uri"
require "pp"
require "webidl"
require "active_support/inflector"

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'body', 'bodys'
  inflect.plural 'tbody', 'tbodys'
  inflect.plural 'canvas', 'canvases'
  inflect.plural 'ins', 'inses'
  inflect.plural /^s$/, 'ss'
  inflect.plural 'meta', 'metas'
  inflect.plural 'details', 'detailses'
  inflect.plural 'data', 'datas'
  inflect.plural 'datalist', 'datalists'
end

require "watir-webdriver/html/util"
require "watir-webdriver/html/visitor"
require "watir-webdriver/html/idl_sorter"
require "watir-webdriver/html/spec_extractor"
require "watir-webdriver/html/generator"