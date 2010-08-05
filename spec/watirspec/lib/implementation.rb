module WatirSpec
  class Implementation

    attr_writer :name, :guard_proc

    def initialize
      @name       = nil
      @guard_proc = nil

      yield self if block_given?
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
      guards.each { |args, data| result << data if matches_guard?(args) }

      result
    end

  end # Implementation
end # WatirSpec