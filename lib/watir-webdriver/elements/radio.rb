# encoding: utf-8
module Watir
  class Radio < Input
    identifier :type => 'radio'

    container_method  :radio
    collection_method :radios

    def set
      assert_exists
      assert_enabled

      @element.click unless set?
    end

    def set?
      assert_exists
      @element.selected?
    end

  end
end
