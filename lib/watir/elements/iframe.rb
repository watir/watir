module Watir
  class IFrame < HTMLElement

    def locate
      return if @selector.empty?
      @query_scope.ensure_context

      selector = @selector.merge(tag_name: frame_tag)
      element_validator = element_validator_class.new
      selector_builder = selector_builder_class.new(@query_scope, selector, self.class.attribute_list)
      @locator = locator_class.new(@query_scope, selector, selector_builder, element_validator)

      element = @locator.locate
      element or raise unknown_exception, "unable to locate #{@selector[:tag_name]} using #{selector_string}"

      @element = FramedDriver.new(element, browser)
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      wd == other.wd.is_a?(FramedDriver) ? other.wd.send(:wd) : other.wd
    end

    def switch_to!
      locate.send :switch!
    end

    def assert_exists
      if @element && @selector.empty?
        raise UnknownFrameException, "wrapping a Selenium element as a Frame is not currently supported"
      end

      super
    end

    #
    # Returns text of iframe body.
    #
    # @return [String]
    #

    def text
      body.text
    end

    #
    # Returns HTML code of iframe.
    #
    # @return [String]
    #

    def html
      wait_for_exists
      @element.page_source
    end

    #
    # Executes JavaScript snippet in context of frame.
    #
    # @see Watir::Browser#execute_script
    #

    def execute_script(script, *args)
      args.map! { |e| e.kind_of?(Watir::Element) ? e.wd : e }
      returned = driver.execute_script(script, *args)

      browser.send(:wrap_elements_in, self, returned)
    end

    def ensure_context
      switch_to!
    end

    private

    def frame_tag
      'iframe'
    end

    def unknown_exception
      Watir::Exception::UnknownFrameException
    end

  end # IFrame


  class IFrameCollection < ElementCollection
  end # IFrameCollection


  class Frame < IFrame

    private

    def frame_tag
      'frame'
    end

  end # Frame


  class FrameCollection < IFrameCollection
  end # FrameCollection


  module Container

    def frame(*args)
      Frame.new(self, extract_selector(args).merge(tag_name: "frame"))
    end

    def frames(*args)
      FrameCollection.new(self, extract_selector(args).merge(tag_name: "frame"))
    end

  end # Container


  # @api private
  #
  # another hack..
  #

  class FramedDriver
    def initialize(element, browser)
      @element = element
      @browser = browser
      @driver = browser.driver
    end

    def ==(other)
      wd == other.wd
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
      @browser.default_context = false
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise Exception::UnknownFrameException, e.message
    end

  end # FramedDriver
end # Watir
