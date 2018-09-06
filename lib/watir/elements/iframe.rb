module Watir
  class IFrame < HTMLElement
    def switch_to!
      locate unless @element
      wd.switch!
    end

    def wd
      super
      FramedDriver.new(@element, browser)
    end

    #
    # Returns text of iframe body.
    # #body ensures context so this method does not have to
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
    # Delegate sending keystrokes to FramedDriver
    #

    def send_keys(*args)
      wd.send_keys(*args)
    end

    #
    # Executes JavaScript snippet in context of frame.
    #
    # @see Watir::Browser#execute_script
    #

    def execute_script(script, *args)
      args.map! { |e| e.is_a?(Watir::Element) ? e.wd : e }
      returned = driver.execute_script(script, *args)

      browser.send(:wrap_elements_in, self, returned)
    end

    protected

    def relocate?
      true
    end

    private

    def unknown_exception
      Watir::Exception::UnknownFrameException
    end
  end # IFrame

  class IFrameCollection < ElementCollection
  end # IFrameCollection

  class Frame < IFrame
  end # Frame

  class FrameCollection < IFrameCollection
  end # FrameCollection

  module Container
    def frame(*args)
      Frame.new(self, extract_selector(args).merge(tag_name: 'frame'))
    end

    def frames(*args)
      FrameCollection.new(self, extract_selector(args).merge(tag_name: 'frame'))
    end
  end # Container

  #
  # @api private
  #

  class FramedDriver
    def initialize(element, browser)
      @element = element
      @browser = browser
      @driver = browser.wd
    end

    def ==(other)
      wd == other.wd
    end
    alias eql? ==

    def send_keys(*args)
      switch!
      @driver.switch_to.active_element.send_keys(*args)
    end

    def switch!
      @driver.switch_to.frame @element
      @browser.default_context = false
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise Exception::UnknownFrameException, e.message
    end

    protected

    def wd
      @element
    end

    private

    def respond_to_missing?(meth)
      @driver.respond_to?(meth) || @element.respond_to?(meth)
    end

    def method_missing(meth, *args, &blk)
      if %i[find_element find_elements].include?(meth)
        @driver.send(meth, *args, &blk)
      elsif @driver.respond_to?(meth)
        switch!
        @driver.send(meth, *args, &blk)
      elsif @element.respond_to?(meth)
        @element.send(meth, *args, &blk)
      else
        super
      end
    end
  end # FramedDriver
end # Watir
