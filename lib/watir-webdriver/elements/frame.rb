# encoding: utf-8
module Watir
  class Frame < HTMLElement

    def locate
      @parent.assert_exists

      element = locate_iframe || locate_frame
      element or raise UnknownFrameException, "unable to locate frame/iframe using #{selector_string}"

      element && FramedDriver.new(element, driver)
    end

    def assert_exists
      if element = @selector[:element]
        @parent.assert_exists
        @element = FramedDriver.new(element, driver)
      else
        # we set @element to nil here to make sure the frame is switched
        @element = nil
      end

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
      IFrame.new(@parent, @selector.merge(:tag_name => "iframe")).locate
    end

    def locate_frame
      locator = locator_class.new(@parent.wd, @selector.merge(:tag_name => "frame"), self.class.attribute_list)
      locator.locate
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
    
    def ==(other)
      @element == other.element
    end
    alias_method :eql?, :==
    
    protected
    
    def element
      @element
    end
    
    private

    def method_missing(meth, *args, &blk)
      if @driver.respond_to?(meth)
        switch!
        @driver.send(meth, *args, &blk)
      else
        @element.send(meth, *args, &blk)
      end
    end

    def switch!
      @driver.switch_to.frame @element
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise UnknownFrameException, e.message
    end

  end # FramedDriver
end # Watir
