module Watir
  class IFrame < HTMLElement

    def locate_in_context
      @selector.merge(tag_name: frame_tag)
      super
    end

    def switch_to!
      wd.send :switch!
    end

    def assert_exists
      super
      if @element && @selector.empty?
        raise UnknownFrameException, "wrapping a Selenium element as a Frame is not currently supported"
      end
    end

    def wd
      super
      @driver ||= FramedDriver.new(@element, browser)
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
      wd.page_source
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

    #
    # Sends sequence of keystrokes to the driver within the frame context.
    #
    # @param [String, Symbol] args
    #

    def send_keys(*args)
      element_call(:wait_for_writable) { wd.send_keys(*args) }
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
    end

    def ==(other)
      wd == other.wd
    end
    alias_method :eql?, :==

    def send_keys(*args)
      switch!
      wd.switch_to.active_element.send_keys(*args)
    end

    protected

    def wd
      @browser.driver
    end

    private

    def method_missing(meth, *args, &blk)
      if wd.respond_to?(meth) && !%i[find_element find_elements].include?(meth)
        switch!
        wd.send(meth, *args, &blk)
      else
        wd.send(meth, *args, &blk)
      end
    end

    def switch!
      wd.switch_to.frame @element
      @browser.default_context = false
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise Exception::UnknownFrameException, e.message
    end

  end # FramedDriver
end # Watir
