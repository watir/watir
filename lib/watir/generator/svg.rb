ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'defs', 'defss'
end

require 'watir/generator/svg/generator'
require 'watir/generator/svg/spec_extractor'
require 'watir/generator/svg/visitor'
