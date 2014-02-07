# encoding: utf-8
module Watir
  class Input < HTMLElement

    def readonly?
      warn '#readonly? is deprecated, use #read_only? instead'
      read_only?
    end

    #
    # Returns true if input is enabled.
    #
    # @return [Boolean]
    #

    def enabled?
      !disabled?
    end

  end # Input
end # Watir
