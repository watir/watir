# encoding: utf-8
module Watir
  class IFrame < HTMLElement

    def locate
      @parent.assert_exists

      locator = locator_class.new(@parent.wd, @selector.merge(:tag_name => tag_name), self.class.attribute_list)
      element = locator.locate
      element or raise UnknownFrameException, "unable to locate #{@selector[:tag_name]} using #{selector_string}"

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

    def tag_name
      'iframe'
    end

  end # IFrame


  class IFrameCollection < ElementCollection

    def to_a
      (0...elements.size).map { |idx| element_class.new @parent, :index => idx }
    end

    def element_class
      IFrame
    end

  end # IFrameCollection


  class Frame < IFrame

    private

    def tag_name
      'frame'
    end

  end # Frame


  class FrameCollection < IFrameCollection

    def element_class
      Frame
    end

  end # FrameCollection


  module Container

    def frame(*args)
      Frame.new(self, extract_selector(args).merge(:tag_name => "frame"))
    end

    def frames(*args)
      FrameCollection.new(self, extract_selector(args).merge(:tag_name => "frame"))
    end

  end # Container


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
