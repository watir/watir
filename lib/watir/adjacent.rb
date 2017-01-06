require "active_support/inflector"

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
      opt[:index] ||= 0
      xpath_adjacent("ancestor::", opt)
    end

    #
    # Returns preceding sibling element of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").preceding_sibling(index: 1) == browser.legend
    #   #=> true
    #

    def preceding_sibling(opt = {})
      opt[:index] ||= 0
      xpath_adjacent("preceding-sibling::", opt)
    end
    alias_method :previous_sibling, :preceding_sibling

    #
    # Returns collection of preceding sibling elements of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").preceding_siblings.size
    #   #=> 3
    #

    def preceding_siblings(opt = {})
      raise ArgumentError, "#previous_siblings can not take an index value" if opt[:index]
      xpath_adjacent("preceding-sibling::", opt)
    end
    alias_method :previous_siblings, :preceding_siblings

    #
    # Returns following sibling element of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").following_sibling(index: 2) == browser.text_field(id: "new_user_last_name")
    #   #=> true
    #

    def following_sibling(opt = {})
      opt[:index] ||= 0
      xpath_adjacent("following-sibling::", opt)
    end
    alias_method :next_sibling, :following_sibling

    #
    # Returns collection of following sibling elements of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").following_siblings.size
    #   #=> 52
    #

    def following_siblings(opt = {})
      raise ArgumentError, "#next_siblings can not take an index value" if opt[:index]
      xpath_adjacent("following-sibling::", opt)
    end
    alias_method :next_siblings, :following_siblings

    #
    # Returns collection of all sibling elements of current element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").following_siblings.size
    #   #=> 52
    #

    def siblings(opt = {})
      raise ArgumentError, "#siblings can not take an index value" if opt[:index]
      preceding_siblings(opt) + following_siblings(opt)
    end

    #
    # Returns element of direct child of current element.
    #
    # @example
    #   browser.form(id: "new_user").child == browser.fieldset
    #   #=> true
    #

    def child(opt = {})
      opt[:index] ||= 0
      xpath_adjacent('', opt)
    end

    #
    # Returns collection of elements of direct children of current element.
    #
    # @example
    #   browser.select_list(id: "new_user_languages").children == browser.select_list(id: "new_user_languages").options.to_a
    #   #=> true
    #

    def children(opt = {})
      raise ArgumentError, "#children can not take an index value" if opt[:index]
      xpath_adjacent('', opt)
    end

    private

    def xpath_adjacent(direction = '', opt = {})
      opt = opt.dup
      index = opt.delete :index
      tag_name = opt.delete :tag_name
      unless opt.empty?
        caller = caller_locations(1, 1)[0].label
        raise ArgumentError, "unsupported locators: #{opt.inspect} for ##{caller} method"
      end

      xpath = "./#{direction}#{tag_name || '*'}"

      if index
        tag_name ||= 'element'
        self.send(tag_name, {xpath: "#{xpath}[#{index + 1}]"})
      else
        return self.send(tag_name.to_s.pluralize, {xpath: xpath}) if tag_name
        MixedElementCollection.new(self, {xpath: xpath})
      end
    end

  end # Adjacent
end # Watir
