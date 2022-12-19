# frozen_string_literal: true

module WatirSpec
  class Implementation
    attr_writer :name, :guard_proc, :browser_class
    attr_accessor :browser_args, :driver_info

    def initialize
      @guard_proc = nil
    end

    def initialize_copy(_orig)
      @browser_args = browser_args.map(&:dup)
    end

    def browser_class
      @browser_class || raise('browser_class not set')
    end

    def name
      @name || raise('implementation name not set')
    end

    def browser_name
      browser_args.first == :ie ? :internet_explorer : browser_args.first
    end

    def matches_guard?(args)
      return @guard_proc.call(args) if @guard_proc

      args.include? name
    end

    def matching_guards_in(guards)
      result = []
      guards.each { |args, data| data.each { |d| result << d } if args.empty? || matches_guard?(args) }

      result
    end

    def inspect_args
      selenium_opts = browser_args.last

      options = selenium_opts.delete(:options)
      args = ["#{browser_args.first} tests:\n"]
      selenium_opts.each { |opt| args << "#{opt.inspect}\n" }

      return "#{browser_args.first} default options" if selenium_opts.empty? && options.nil?

      args << "\toptions:\n"
      options.each { |k, v| args << "\t\t#{k}: #{v}\n" }

      args.join
    end
  end # Implementation
end # WatirSpec
