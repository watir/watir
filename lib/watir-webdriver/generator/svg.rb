ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'defs', 'defss'
end

require "watir-webdriver/generator/svg/generator"
require "watir-webdriver/generator/svg/spec_extractor"
require "watir-webdriver/generator/svg/visitor"
