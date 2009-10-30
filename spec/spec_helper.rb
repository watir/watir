$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'watir'
require 'spec'
require 'spec/autorun'

include Watir


Spec::Runner.configure do |config|
  
end
