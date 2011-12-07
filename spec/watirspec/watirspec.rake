begin
  require 'rspec'
rescue LoadError
  begin
    require 'rubygems'
    require 'rspec'
  rescue LoadError
      puts <<-EOS
    To use rspec for testing you must install rspec gem:
        gem install rspec
    EOS
      exit(0)
  end
end

require 'rspec/core/rake_task'
namespace :watirspec do
  desc "Run the specs under #{File.dirname(__FILE__)}"
  RSpec::Core::RakeTask.new(:run) do |t|
    t.pattern = "#{File.dirname(__FILE__)}/*_spec.rb"
  end
end


namespace :watirspec do
  def watirspec_config; "#{File.dirname(__FILE__)}/.git/config"; end

  #
  # stolen from rubinius
  #

  desc 'Switch to the committer url for watirspec'
  task :committer do
    system "git config --file #{watirspec_config} remote.origin.url git@github.com:jarib/watirspec.git"
    puts "\nYou're now accessing watirspec via the committer URL."
  end

  desc "Switch to the watirspec anonymous URL"
  task :anon do
    system "git config --file #{watirspec_config} remote.origin.url git://github.com/jarib/watirspec.git"
    puts "\nYou're now accessing watirspec via the anonymous URL."
  end
end
