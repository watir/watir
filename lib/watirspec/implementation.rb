module WatirSpec
  class Implementation

    attr_writer :name, :guard_proc, :browser_class
    attr_accessor :browser_args

    def initialize
      @guard_proc = nil
    end

    def browser_class
      @browser_class || raise("browser_class not set")
    end

    def name
      @name || raise("implementation name not set")
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

  end # Implementation
end # WatirSpec
