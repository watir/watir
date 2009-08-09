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
