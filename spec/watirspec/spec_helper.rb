# encoding: utf-8
begin
  require "rubygems"
rescue LoadError
end

require "tmpdir"
require "sinatra/base"
require "#{File.dirname(__FILE__)}/lib/watirspec"
require "#{File.dirname(__FILE__)}/lib/implementation"
require "#{File.dirname(__FILE__)}/lib/server"
require "#{File.dirname(__FILE__)}/lib/runner"
require "#{File.dirname(__FILE__)}/lib/guards"
require "#{File.dirname(__FILE__)}/lib/silent_logger"

if __FILE__ == $0
  # this is needed in order to have a stable Server on Windows + MRI
  WatirSpec::Server.run!
else
  WatirSpec::Runner.execute_if_necessary
end

