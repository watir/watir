module WatirSpec
  module Guards

    class << self
      def guards
        @guards ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def record(guard_name, impls, data)
        impls.each do |impl|
          guards[impl] << [guard_name, data]
        end
      end

      def report
        gs = guards[WatirSpec.implementation]
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
    end

    def deviates_on(*impls)
      Guards.record :deviates_on, impls, :file => caller.first
      return yield if WatirSpec.unguarded?
      yield if impls.include? WatirSpec.implementation
    end

    def not_compliant_on(*impls)
      Guards.record :not_compliant_on, impls, :file => caller.first
      return yield if WatirSpec.unguarded?
      yield unless impls.include? WatirSpec.implementation
    end

    def compliant_on(*impls)
      Guards.record :compliant_on, impls, :file => caller.first
      return yield if WatirSpec.unguarded?
      yield if impls.include? WatirSpec.implementation
    end

    def bug(key, *impls)
      Guards.record :bug, impls, :file => caller.first, :key => key
      return yield if WatirSpec.unguarded?
      yield unless impls.include? WatirSpec.implementation
    end
  end
end

class Object
  include WatirSpec::Guards
end