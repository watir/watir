# encoding: utf-8

module Watir

  #
  # Base class for HTML elements.
  #

  class Element
    include Exception
    include Container
    include Selenium
    extend AttributeHelper

    def initialize(parent, selector)
      @parent   = parent
      @selector = selector

      unless @selector.kind_of? Hash
        raise ArgumentError, "invalid argument: #{selector.inspect}"
      end

      if @selector.has_key?(:element)
        @element = @selector[:element]
      end
    end

    def exists?
      assert_exists
      true
    rescue UnknownObjectException, UnknownFrameException
      false
    end
    alias_method :exist?, :exists?

    def inspect
      if @selector.has_key?(:element)
        '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, '{:element=>(webdriver element)}']
      else
        '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, selector_string]
      end
    end

    def ==(other)
      assert_exists
      @element == other.element
    end
    alias_method :eql?, :==

    def hash
      @element ? @element.hash : super
    end

    def text
      assert_exists
      @element.text
    end

    def tag_name
      assert_exists
      @element.tag_name
    end

    def click
      assert_exists
      assert_enabled
      @element.click
      run_checkers
    end

    def double_click
      assert_exists
      raise NotImplementedError, "need support in WebDriver"

      @element.double_click
      run_checkers
    end

    def right_click
      assert_exists
      raise NotImplementedError, "need support in WebDriver"

      @element.right_click
      run_checkers
    end

    def flash
      original_color = style("backgroundColor")

      10.times do |n|
        color = (n % 2 == 0) ? "red" : original_color
        driver.execute_script("arguments[0].style.backgroundColor = '#{color}'", @element)
      end
    end

    def value
      assert_exists

      begin
        @element.value || ''
      rescue WebDriver::Error::ElementNotEnabledError
        ""
      end
    end

    def attribute_value(attribute_name)
      assert_exists
      @element.attribute attribute_name
    end

    def html
      assert_exists
      browserbot('getOuterHTML', @element).strip
    end

    def send_keys(*args)
      assert_exists
      @element.send_keys(*args)
    end

    #
    # Note: Firefox queues focus events until the window actually has focus.
    #
    # See http://code.google.com/p/selenium/issues/detail?id=157
    #

    def focus
      assert_exists
      driver.execute_script "return arguments[0].focus()", @element
    end

    def fire_event(event_name, bubble = false)
      assert_exists
      event_name = event_name.to_s.sub(/^on/, '')
      browserbot('triggerEvent', @element, event_name, bubble)
    end

    def parent
      assert_exists

      e = driver.execute_script "return arguments[0].parentNode", @element

      if e.kind_of?(WebDriver::Element)
        Watir.element_class_for(e.tag_name).new(@parent, :element => e)
      end
    end

    def driver
      @parent.driver
    end

    def element
      assert_exists
      @element
    end
    alias_method :wd, :element # ensures duck typing with Browser

    def visible?
      assert_exists
      @element.displayed?
    end

    def style(property = nil)
      if property
        assert_exists
        @element.style property
      else
        attribute_value("style") || ''
      end
    end

    def run_checkers
      @parent.run_checkers
    end

  protected

    def assert_exists
      @element ||= locate

      unless @element
        raise UnknownObjectException, "unable to locate element, using #{selector_string}"
      end
    end

    def browser
      @parent.browser
    end

    def locate
      @parent.assert_exists
      ElementLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

  private

    def selector_string
      @selector.inspect
    end

    def attribute?(attribute)
      assert_exists
      driver.execute_script "return !!arguments[0].getAttributeNode(arguments[1]);", @element, attribute.to_s.downcase
    end

    def assert_enabled
      raise ObjectDisabledException, "object is disabled #{selector_string}" unless @element.enabled?
    end

    def assert_writable
      assert_enabled
      raise ObjectReadOnlyException if respond_to?(:readonly?) && readonly?
    end

    def method_missing(meth, *args, &blk)
      meth = meth.to_s
      if meth =~ /^data_(.*)$/
        attribute_value(meth.gsub(/_/, '-'), *args)
      else
        super
      end
    end

  end # Element
end # Watir
