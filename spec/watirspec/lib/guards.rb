module WatirSpec
  module Guards

    def deviates_on(*impls)
      return yield if WatirSpec.unguarded?
      yield if impls.include? WatirSpec.implementation
    end

    def not_compliant_on(*impls)
      return yield if WatirSpec.unguarded?
      yield unless impls.include? WatirSpec.implementation
    end

    def compliant_on(*impls)
      return yield if WatirSpec.unguarded?
      yield if impls.include? WatirSpec.implementation
    end

    def bug(key, *impls)
      return yield if WatirSpec.unguarded?
      yield unless impls.include? WatirSpec.implementation
    end
  end
end