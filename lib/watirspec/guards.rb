module WatirSpec
  module Guards
    class << self
      def guards
        @guards ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def record(guard_name, impls, data)
        guards[impls] << {name: guard_name, data: data}
      end

      def report
        gs = WatirSpec.implementation.matching_guards_in(guards)
        str = "WatirSpec guards for this implementation: \n"

        if gs.empty?
          "\tnone."
        else
          gs.each do |guard|
            guard[:data][:file] = guard[:data][:file][%r{\/spec\/(.*):}, 1]
            guard_name = "#{guard[:name]}:".ljust(15)
            str << " \t#{guard_name} #{guard[:data].inspect}\n"
          end
          Watir.logger.warn str, ids: [:guard_names]
        end
      end
    end # class << self

    private

    def deviates_on(*impls)
      Guards.record :deviates, impls, file: caller(1..1).first
      return yield if WatirSpec.unguarded?

      yield if WatirSpec.implementation.matches_guard?(impls)
    end

    def not_compliant_on(*impls)
      Guards.record :not_compliant, impls, file: caller(1..1).first
      return yield if WatirSpec.unguarded?

      yield unless WatirSpec.implementation.matches_guard?(impls)
    end

    def compliant_on(*impls)
      Guards.record :compliant, impls, file: caller(1..1).first
      return yield if WatirSpec.unguarded?

      yield if WatirSpec.implementation.matches_guard?(impls)
    end

    def bug(key, *impls)
      Guards.record :bug, impls, file: caller(1..1).first, key: key
      return yield if WatirSpec.unguarded?

      yield if impls.any? && !WatirSpec.implementation.matches_guard?(impls)
    end
  end
end

class Object
  include WatirSpec::Guards
end
