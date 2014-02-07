# encoding: utf-8
module Watir
  class Area < HTMLElement

    #
    # @todo temporarily add href attribute
    #
    # @see https://www.w3.org/Bugs/Public/show_bug.cgi?id=23192
    #
    attribute :string, :href

  end # Area
end # Watir
