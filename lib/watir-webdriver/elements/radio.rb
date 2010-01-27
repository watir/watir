# encoding: utf-8
module Watir
  class Radio < Input
    identifier :type => 'radio'

    container_method  :radio
    collection_method :radios

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
