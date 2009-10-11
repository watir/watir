# encoding: utf-8
begin
  require "rubygems"
rescue LoadError
end

require "sinatra/base"
require "#{File.dirname(__FILE__)}/lib/watirspec"
require "#{File.dirname(__FILE__)}/lib/server"
require "#{File.dirname(__FILE__)}/lib/spec_helper"
require "#{File.dirname(__FILE__)}/lib/guards"

if __FILE__ == $0
  WatirSpec::Server.run!
else
  WatirSpec::SpecHelper.execute
end
