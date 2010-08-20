# encoding: utf-8
module Watir
  class Radio < Input
    #
    # Select this radio button.
    #

    def set
      assert_exists
      assert_enabled

      @element.click unless set?
    end

    #
    # Is this radio set?
    #

    def set?
      assert_exists
      @element.selected?
    end
  end # Radio

  module Container
    def radio(*selectors)
      Radio.new(self, { :tag_name => "input", :type => "radio" }, *selectors)
    end

    def radios(*selectors)
      RadioCollection.new(self, { :tag_name => "input", :type => "radio" }, *selectors)
    end
  end # Container

  class RadioCollection < InputCollection
    private

    def element_class
      Radio
    end
  end # RadioCollection
end # Watir
