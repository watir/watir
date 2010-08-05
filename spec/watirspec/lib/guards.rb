module WatirSpec
  module Guards

    class << self
      def guards
        @guards ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def record(guard_name, impls, data)
        guards[impls] << [guard_name, data]
      end

      def report
        gs = WatirSpec.implementation.matching_guards_in(guards)
        print "\n\nWatirSpec guards for this implementation: "
        
        if gs.empty?
         puts "none."
        else
          puts
          gs.each do |guard_name, data|
            puts "\t#{guard_name.to_s.ljust(20)}: #{data.inspect}"
          end
        end
      end
    end # class << self

    private

    def deviates_on(*impls)
      Guards.record :deviates, impls, :file => caller.first
      return yield if WatirSpec.unguarded?
      yield if WatirSpec.implementation.matches_guard?(impls)
    end

    def not_compliant_on(*impls)
      Guards.record :not_compliant, impls, :file => caller.first
      return yield if WatirSpec.unguarded?
      yield unless WatirSpec.implementation.matches_guard?(impls)
    end

    def compliant_on(*impls)
      Guards.record :compliant, impls, :file => caller.first
      return yield if WatirSpec.unguarded?
      yield if WatirSpec.implementation.matches_guard?(impls)
    end

    def bug(key, *impls)
      Guards.record :bug, impls, :file => caller.first, :key => key
      return yield if WatirSpec.unguarded?
      yield unless WatirSpec.implementation.matches_guard?(impls)
    end
  end
end

class Object
  include WatirSpec::Guards
end