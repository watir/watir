$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if ENV['GITHUB_ACTIONS'] || ENV['COVERAGE']
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
require 'webdrivers'
require 'locator_spec_helper'
require 'rspec'

if ENV['GITHUB_ACTIONS']
  require 'rspec/retry'
  RSpec.configure do |config|
    config.verbose_retry = true
    config.display_try_failure_messages = true
    config.default_retry_count = 3
    config.exceptions_to_retry = [IOError, Net::ReadTimeout]
  end
end
