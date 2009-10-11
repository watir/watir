module WatirSpec
  module Guards

    class << self
      def report
        @report ||= Hash.new { |hash, key| hash[key] = [] }
      end
    end

    def deviates_on(*impls)
      Guards.report[:deviates_on] << [caller.first, impls]
      return yield if WatirSpec.unguarded?
      yield if impls.include? WatirSpec.implementation
    end

    def not_compliant_on(*impls)
      Guards.report[:not_compliant_on] << [caller.first, impls]
      return yield if WatirSpec.unguarded?
      yield unless impls.include? WatirSpec.implementation
    end

    def compliant_on(*impls)
      Guards.report[:compliant_on] << [caller.first, impls]
      return yield if WatirSpec.unguarded?
      yield if impls.include? WatirSpec.implementation
    end

    def bug(key, *impls)
      Guards.report[:bug] << [caller.first, key, impls]
      return yield if WatirSpec.unguarded?
      yield unless impls.include? WatirSpec.implementation
    end
  end
end

Object.extend(WatirSpec::Guards)