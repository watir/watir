# encoding: utf-8
module Watir
  class Frame < HTMLElement

    VALID_LOCATORS = [:id, :name, :index]

    def initialize(*args)
      super
      @frame_id = nil
    end

    def locate
      @parent.assert_exists

      if @iframe
        return @iframe
      elsif @frame_id.nil?
        locate_iframe || locate_frame
      else
        switch!
        driver
      end
    end

    def assert_exists
      @parent.assert_exists
      # we always run locate(), to make sure the frame is switched
      @element = locate
    end

    def execute_script(*args)
      browser.execute_script(*args)
    end

    def element_by_xpath(*args)
      assert_exists
      super
    end

    def elements_by_xpath(*args)
      assert_exists
      super
    end

    private

    def locate_iframe
      # hack - frame doesn't have IFrame's attributes either
      @iframe = @element = IFrame.new(@parent, @selector).locate
    end

    def locate_frame
      loc = VALID_LOCATORS.find { |loc| @selector[loc] }

      unless loc
        raise MissingWayOfFindingObjectException, "can only switch frames by #{VALID_LOCATORS.inspect}"
      end

      @frame_id = @selector[loc]

      unless [String, Integer].any? { |e| @frame_id.kind_of?(e) }
        raise TypeError, "can't locate frame using #{@frame_id.inspect}:#{@frame_id.class}"
      end

      switch!

      driver
    end

    def switch!
      driver.switch_to.frame @frame_id
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise Exception::UnknownFrameException, e.message
    end

  end # Frame
end # Watir
