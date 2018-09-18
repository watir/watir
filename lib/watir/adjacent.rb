module Watir
  module Adjacent
    #
    # Returns parent element of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").parent == browser.fieldset
    #   #=> true
    #

    def parent(opt = {})
      xpath_adjacent(opt.merge(adjacent: :ancestor, plural: false))
    end

    #
    # Returns preceding sibling element of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").preceding_sibling(index: 1) == browser.legend
    #   #=> true
    #

    def preceding_sibling(opt = {})
      xpath_adjacent(opt.merge(adjacent: :preceding, plural: false))
    end
    alias previous_sibling preceding_sibling

    #
    # Returns collection of preceding sibling elements of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").preceding_siblings.size
    #   #=> 3
    #

    def preceding_siblings(opt = {})
      raise ArgumentError, '#previous_siblings can not take an index value' if opt[:index]

      xpath_adjacent(opt.merge(adjacent: :preceding, plural: true))
    end
    alias previous_siblings preceding_siblings

    #
    # Returns following sibling element of current element.
    #
    # @example
    #   following_sibling = browser.text_field(name: "new_user_first_name").following_sibling(index: 2)
    #   following_sibling == browser.text_field(id: "new_user_last_name")
    #   #=> true
    #

    def following_sibling(opt = {})
      xpath_adjacent(opt.merge(adjacent: :following, plural: false))
    end
    alias next_sibling following_sibling

    #
    # Returns collection of following sibling elements of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").following_siblings.size
    #   #=> 55
    #

    def following_siblings(opt = {})
      raise ArgumentError, '#next_siblings can not take an index value' if opt[:index]

      xpath_adjacent(opt.merge(adjacent: :following, plural: true))
    end
    alias next_siblings following_siblings

    #
    # Returns collection of siblings of current element, including current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").siblings.size
    #   #=> 59
    #

    def siblings(opt = {})
      parent.children(opt)
    end

    #
    # Returns element of direct child of current element.
    #
    # @example
    #   browser.form(id: "new_user").child == browser.fieldset
    #   #=> true
    #

    def child(opt = {})
      xpath_adjacent(opt.merge(adjacent: :child, plural: false))
    end

    #
    # Returns collection of elements of direct children of current element.
    #
    # @example
    #   children = browser.select_list(id: "new_user_languages").children
    #   children == browser.select_list(id: "new_user_languages").options.to_a
    #   #=> true
    #

    def children(opt = {})
      raise ArgumentError, '#children can not take an index value' if opt[:index]

      xpath_adjacent(opt.merge(adjacent: :child, plural: true))
    end

    private

    def xpath_adjacent(opt = {})
      plural = opt.delete(:plural)
      opt[:index] ||= 0 unless plural || opt.values.any? { |e| e.is_a? Regexp }
      klass = if !plural && opt[:tag_name]
                Watir.element_class_for(opt[:tag_name])
              elsif !plural
                HTMLElement
              elsif opt[:tag_name]
                Object.const_get("#{Watir.element_class_for(opt[:tag_name])}Collection")
              else
                HTMLElementCollection
              end
      klass.new(self, opt)
    end
  end # Adjacent
end # Watir
