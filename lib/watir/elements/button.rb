# encoding: utf-8
module Watir
  class Button < HTMLElement

    # add the attributes from <input>
    attributes Watir::Input.typed_attributes

    def locate
      ButtonLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

    def enabled?
      !disabled?
    end

  end
end
