module Watir

  #
  # Base class for mixed element collections.
  #

  class MixedElementCollection < ElementCollection

    #
    # This collection as an Array.
    #
    # @return [Array<Watir::Element>]
    #

    def to_a
      @to_a ||= elements.map.with_index do |e, idx|
        Watir::HTMLElement.new(@query_scope, @selector.merge(element: e, index: idx)).to_subtype
      end
    end

    #
    # Creates a MixedElementCollection containing elements of two collections.
    #
    # @example
    #   (browser.select_list(name: "new_user_languages").children + browser.select_list(id: "new_user_role").children).size
    #   #=> 8
    #

    def +(other)
      case
      when to_a.empty?
        other
      when other.to_a.empty?
        self
      else
        other.to_a.each { |el| to_a << el }
        @to_a = to_a
        self
      end
    end

    private

    def element_class_name
      "HTMLElement"
    end

    def element_class
      Watir::HTMLElement
    end

  end # ElementCollection
end # Watir
