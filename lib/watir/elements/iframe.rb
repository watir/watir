module Watir
  class IFrame < HTMLElement
    #
    # Move Driver context into the iframe
    #

    def switch_to!
      locate unless located?
      wd.switch!
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
      args.map! do |e|
        e.is_a?(Element) ? e.wait_until(&:exists?).wd : e
      end
      returned = driver.execute_script(script, *args)

      browser.wrap_elements_in(self, returned)
    end

    #
    # Provides access to underlying Selenium Objects as delegated by FramedDriver
    #
    # @return [Watir::FramedDriver]
    #

    def wd
      super
      FramedDriver.new(@element, browser)
    end

    #
    # Cast this Element instance to a more specific subtype.
    # Cached element needs to be the IFrame element, not the FramedDriver
    #

    def to_subtype
      super.tap { |el| el.cache = @element }
    end

    private

    def unknown_exception
      UnknownFrameException
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
    include Exception

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
      @browser.after_hooks.run
    rescue Selenium::WebDriver::Error::NoSuchFrameError => e
      raise UnknownFrameException, e.message
    end

    def wd
      @element
    end

    def respond_to_missing?(meth, _include_private = false)
      @driver.respond_to?(meth) || @element.respond_to?(meth) || super
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
