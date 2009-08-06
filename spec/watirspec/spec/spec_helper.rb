require "fileutils"

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

Thread.abort_on_exception = true

require "#{File.dirname(__FILE__)}/../watirspec"
hook = File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper.rb")

if File.exist?(hook)
  require hook 
else
  raise Errno::ENOENT, hook
end

WatirSpec::Server.run!
