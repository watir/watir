require 'rake/tasklib'

module WatirSpec
  class RakeTasks < Rake::TaskLib
    def initialize
      namespace :watirspec do
        desc 'Initialize WatirSpec'
        task :init do
          init_watirspec
          print_usage
        end

        desc 'List WatirSpec examples'
        task :list do
          print_specs
        end

        desc 'Run WatirSpec examples'
        task :run, %i[spec line] do |_, args|
          run(args)
        end
      end
    end

    private

    def init_watirspec
      Dir.mkdir('spec') unless Dir.exist?('spec')
      return if File.exist?('spec/watirspec_helper.rb')

      File.open('spec/watirspec_helper.rb', 'w') do |file|
        file.write(watirspec_helper_template)
      end
    end

    def print_specs
      puts "The following spec files are present:\n\n"
      spec_files.each do |file|
        filename = file.sub("#{watirspec_path}/", '')
        puts "  #{filename}"
      end
    end

    def run(**args)
      return if system(rspec_command(args))

      exit $CHILD_STATUS.exitstatus || 1
    end

    def rspec_command(**args)
      cmd = [rspec_binary]
      if args[:spec]
        spec_file = spec_files.find { |file| file == "#{watirspec_path}/#{args[:spec]}_spec.rb" }
        spec_file << ":#{args[:line]}" if args[:line]
        cmd << spec_file
      else
        cmd << spec_files
      end

      cmd.join(' ')
    end

    def spec_files
      Dir.glob("#{watirspec_path}/**/*_spec.rb")
    end

    def rspec_binary
      rspec_path = Bundler.rubygems.find_name('rspec-core').first.full_gem_path
      "#{rspec_path}/exe/rspec"
    end

    def watirspec_path
      watir_path = Bundler.rubygems.find_name('watir').first.full_gem_path
      "#{watir_path}/spec/watirspec"
    end

    def watirspec_helper_template
      <<~RUBY
        require 'watirspec'
        # require your gems

        WatirSpec.implementation do |watirspec|
          # add WatirSpec implementation (see example below)
          #
          # watirspec.name = :watizzle
          # watirspec.browser_class = Watir::Browser
          # watirspec.browser_args = [:firefox, {}]
          # watirspec.guard_proc = lambda do |args|
          #   args.include?(:firefox)
          # end
        end

        WatirSpec.run!
      RUBY
    end

    def print_usage
      p <<~PRINT_USAGE
        File spec/watirspec_helper.rb is successfully created!
        Please, check it and customize for your needs. Once done, you can start using WatirSpec.

        Run all WatirSpec examples:
          $ bundle exec rake watirspec:run

        Run specific WatirSpec example:
          $ bundle exec rake watirspec:run[elements/div]

        Run WatirSpec example on a custom line:
          $ bundle exec rake watirspec:run[elements/div, 50]

        List all WatirSpec examples:
          $ bundle exec rake watirspec:list
      PRINT_USAGE
    end
  end
end
