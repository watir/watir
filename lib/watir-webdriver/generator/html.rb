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

require "watir-webdriver/generator/html/generator"
require "watir-webdriver/generator/html/spec_extractor"
require "watir-webdriver/generator/html/visitor"
