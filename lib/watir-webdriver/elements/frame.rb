# encoding: utf-8
module Watir
  class Frame < HTMLElement

    def locate
      @parent.assert_exists

      element = locate_iframe || locate_frame
      element or raise UnknownFrameException, "unable to locate frame/iframe using #{selector_string}"

      @parent.reset!

      FramedDriver.new(element, driver)
    end

    def assert_exists
      if @selector.has_key? :element
        raise UnknownFrameException, "wrapping a WebDriver element as a Frame is not currently supported"
      end

      if @element && !Watir.always_locate?
        begin
          @element.tag_name # rpc
          return @element
        rescue Selenium::WebDriver::Error::ObsoleteElementError
          @element = nil # re-locate
        end
      end

      super
    end

    def html
      assert_exists

      # this will actually give us the innerHTML instead of the outerHTML of the <frame>,
      # but given the choice this seems more useful
      execute_atom(:getOuterHtml, @element.find_element(:tag_name => "html")).strip
    end

    def execute_script(*args)
      browser.execute_script(*args)
    end

    private

    def locate_iframe
      locator = locator_class.new(@parent.wd, @selector.merge(:tag_name => "iframe"), attribute_list)
      locator.locate
    end

    def locate_frame
      locator = locator_class.new(@parent.wd, @selector.merge(:tag_name => "frame"), attribute_list)
      locator.locate
    end

    def attribute_list
      self.class.attribute_list | IFrame.attribute_list
    end
  end # Frame

  module Container
    def frame(*args)
      Frame.new(self, extract_selector(args))
    end

    def frames(*args)
      FrameCollection.new(self, extract_selector(args).merge(:tag_name => /^(iframe|frame)$/)) # hack
    end

    def iframe(*args)
      warn "Watir::Container#iframe is replaced by Watir::Container#frame"
      frame(*args)
    end

    def iframes(*args)
      warn "Watir::Container#iframes is replaced by Watir::Container#frames"
      frame(*args)
    end
  end

  class FrameCollection < ElementCollection
    def to_a
      (0...elements.size).map { |idx| element_class.new @parent, :index => idx }
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
      @element == other.wd
    end
    alias_method :eql?, :==

    def send_keys(*args)
      switch!
      @driver.switch_to.active_element.send_keys(*args)
    end

    protected

    def wd
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
