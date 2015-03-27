# encoding: utf-8
module SportNgin
	module Watir
  class Radio < Input

    #
    # Selects this radio button.
    #

    def set
      @timer.wait(@default_timeout) { present? }
      click unless set?
    end

    #
    # Is this radio set?
    #
    # @return [Boolean]
    #

    def set?
      @timer.wait(@default_timeout) { present? }
      assert_exists
      element_call { @element.selected? }
    end

  end # Radio

  module Container
    def radio(*args)
      Radio.new(self, extract_selector(args).merge(:tag_name => "input", :type => "radio"))
    end

    def radios(*args)
      RadioCollection.new(self, extract_selector(args).merge(:tag_name => "input", :type => "radio" ))
    end
  end # Container

  class RadioCollection < InputCollection
    private

    def element_class
      Radio
    end
  end # RadioCollection
end # Watir
end # SportNgin
