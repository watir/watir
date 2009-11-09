$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# TODO: fix hardcoded path to WD
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../../selenium/webdriver/common/src/rb/lib"
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../../selenium/webdriver/firefox/src/rb/lib"

require 'watir'
require 'spec'
require 'spec/autorun'

include Watir
include Watir::Exceptions

WatirSpec.browser_args = [:firefox]
WatirSpec.implementation = :watir2