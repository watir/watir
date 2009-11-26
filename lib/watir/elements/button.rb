# encoding: utf-8
module Watir
  class Button < HTMLElement

    # add the attributes from <input>
    attributes Watir::Input.typed_attributes

    def locate
      ButtonLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

    def text
      assert_exists
      case @element.tag_name
      when 'input'
        value
      when 'button'
        text
      end
    end

    def enabled?
      !disabled?
    end

  end
end
