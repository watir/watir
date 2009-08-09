begin
  require 'spec'
rescue LoadError
  begin 
    require 'rubygems'
    require 'spec'
    require 'spec/rake/spectask'
  rescue LoadError
      puts <<-EOS
    To use rspec for testing you must install rspec gem:
        gem install rspec
    EOS
      exit(0)
  end
end



namespace :watirspec do
  desc "Run the specs under spec/"
  Spec::Rake::SpecTask.new(:run) do |t|
    t.spec_files = FileList["#{File.dirname(__FILE__)}/*_spec.rb"]
  end
end


namespace :watirspec do
  def spec_watir; File.dirname(__FILE__); end

  #
  # stolen from rubinius
  #

  desc 'Switch to the committer url for watirspec'
  task :committer do
    Dir.chdir spec_watir do
      sh "git config remote.origin.url git@github.com:jarib/watirspec.git"
    end
    puts "\nYou're now accessing watirspec via the committer URL."
  end

  desc "Switch to the watirspec anonymous URL"
  task :anon do
    Dir.chdir spec_watir do
      sh "git config remote.origin.url git://github.com/jarib/watirspec.git"
    end
    puts "\nYou're now accessing watirspec via the anonymous URL."
  end

end
