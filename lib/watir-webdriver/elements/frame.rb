# encoding: utf-8
module Watir
  class Frame < HTMLElement

    def locate
      @parent.assert_exists

      if element = @iframe
        driver.switch_to.frame @iframe
      elsif element = @frame
        switch!
      else
        element = locate_iframe || locate_frame
        element or raise UnknownFrameException, "unable to locate frame/iframe using #{selector_string}"
      end

      element && FramedDriver.new(element, driver)
    end

    def assert_exists
      # we set @element to nil here to make sure the frame is switched
      # if it's in the selector, that's equally good
      @element = @selector[:element]
      super
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
      @iframe = IFrame.new(@parent, @selector.merge(:tag_name => "iframe")).locate

      if @iframe
        driver.switch_to.frame @iframe
        @iframe
      end
    end

    def locate_frame
      locator = locator_class.new(@parent.wd, @selector.merge(:tag_name => "frame"), self.class.attribute_list)
      @frame = locator.locate

      if @frame
        switch!
        @frame
      end
    end

    def switch!
      driver.switch_to.frame @frame
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise UnknownFrameException, e.message
    end

  end # Frame

  module Container
    def frame(*args)
      Frame.new(self, extract_selector(args))
    end

    def frames(*args)
      FrameCollection.new(self, extract_selector(args).merge(:tag_name => /^(iframe|frame)$/)) # hack
    end
  end

  # @api private
  #
  # another hack..
  #

  class FramedDriver
    def initialize(element, driver)
      @element = element
      @driver = driver
    end

    def method_missing(meth, *args, &blk)
      if @driver.respond_to?(meth)
        @driver.send(meth, *args, &blk)
      else
        @element.send(meth, *args, &blk)
      end
    end
  end # FramedDriver
end # Watir
