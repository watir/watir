# encoding: utf-8
module Watir
  class Radio < Input
    container_method  :radio,  :tag_name => "input", :type => "radio"
    collection_method :radios, :tag_name => "input", :type => "radio"

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

  end
end
