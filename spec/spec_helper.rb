$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if ENV['COVERAGE']
  require 'coveralls'
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [Coveralls::SimpleCov::Formatter,
                                                                  SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::Console]
  SimpleCov.start do
    add_filter %r{/spec/}
    add_filter 'lib/watir/elements/html_elements.rb'
    add_filter 'lib/watir/elements/svg_elements.rb'
    add_filter 'lib/watirspec'
    refuse_coverage_drop
  end
end

require 'watir'
require 'locator_spec_helper'
require 'rspec'
