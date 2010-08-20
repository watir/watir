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
        switch_to_iframe(@iframe)
        driver
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
      @iframe = IFrame.new(@parent, @selector).locate

      if @iframe
        switch_to_iframe @iframe
        driver
      end
    end

    def locate_frame
      loc = VALID_LOCATORS.find { |loc| @selector[loc] }

      unless loc
        raise MissingWayOfFindingObjectException, "can only locate frames by #{VALID_LOCATORS.inspect}"
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
      raise UnknownFrameException, e.message
    end

    def switch_to_iframe(element)
      loc = [:id, :name].find { |e| not [nil, ""].include?(element.attribute(e)) }
      if loc.nil?
        raise MissingWayOfFindingObjectException, "can't switch to frame without :id or :name"
      end

      # TODO: get rid of this when we can switch to elements
      # http://groups.google.com/group/selenium-developers/browse_thread/thread/428bd68e9e8bfecd/19a02ecd20835249

      if @parent.kind_of? Frame
        parent_id = @parent.instance_variable_get("@frame_id")
        loc = [parent_id, element.attribute(loc)].join(".")
      else
        loc = element.attribute(loc)
      end

      driver.switch_to.frame loc
    end
  end # Frame

  module Container
    def frame(*args)
      Frame.new(self, extract_selector(args))
    end

    def frames(*args)
      FrameCollection.new(self, extract_selector(args))
    end
  end

  class FrameCollection < ElementCollection
    def element_class
      Frame
    end
  end

end # Watir
