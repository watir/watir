module Watir
  class IFrame < HTMLElement

    def locate
      @parent.assert_exists

      selector = @selector.merge(tag_name: frame_tag)
      element_validator = element_validator_class.new
      selector_builder = selector_builder_class.new(@parent, selector, self.class.attribute_list)
      locator = locator_class.new(@parent, selector, selector_builder, element_validator)

      element = locator.locate
      element or raise UnknownFrameException, "unable to locate #{@selector[:tag_name]} using #{selector_string}"

      FramedDriver.new(element, driver)
    end

    def switch_to!
      locate.send :switch!
    end

    def assert_exists
      if @selector.key? :element
        raise UnknownFrameException, "wrapping a WebDriver element as a Frame is not currently supported"
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
      assert_exists
      wd.page_source
    end

    def execute_script(*args)
      browser.execute_script(*args)
    end

    private

    def frame_tag
      'iframe'
    end

  end # IFrame


  class IFrameCollection < ElementCollection

    def to_a
      # In case `#all_elements` returns empty array, but `#elements`
      # returns non-empty array (i.e. any frame has loaded between these two calls),
      # index will return nil. That's why `#all_elements` should always
      # be called after `#elements.`
      element_indexes = elements.map { |el| all_elements.index(el) }
      element_indexes.map { |idx| element_class.new(@parent, tag_name: @selector[:tag_name], index: idx) }
    end

    private

    def all_elements
      selector = { tag_name: @selector[:tag_name] }

      element_validator = element_validator_class.new
      selector_builder = selector_builder_class.new(@parent, selector, element_class.attribute_list)
      locator = locator_class.new(@parent, selector, selector_builder, element_validator)

      locator.locate_all
    end

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
    def initialize(element, driver)
      @element = element
      @driver = driver
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
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise Exception::UnknownFrameException, e.message
    end

  end # FramedDriver
end # Watir
