# encoding: utf-8

module Watir

  #
  # Base class for HTML elements.
  #

  class Element
    extend AttributeHelper

    include Exception
    include Container
    include Selenium
    include EventuallyPresent

    def initialize(parent, selector)
      @parent   = parent
      @selector = selector

      unless @selector.kind_of? Hash
        raise ArgumentError, "invalid argument: #{selector.inspect}"
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
      return false unless other.kind_of? self.class

      assert_exists
      @element == other.wd
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
      @element.tag_name.downcase
    end

    def click
      assert_exists
      assert_enabled
      @element.click
      run_checkers
    end

    def double_click
      assert_exists

      unless driver.kind_of? WebDriver::DriverExtensions::HasInputDevices
        raise NotImplementedError, "Element#double_click is not supported by this driver"
      end

      driver.action.double_click(@element).perform
      run_checkers
    end

    def right_click
      assert_exists

      unless driver.kind_of? WebDriver::DriverExtensions::HasInputDevices
        raise NotImplementedError, "Element#context_click is not supported by this driver"
      end

      driver.action.context_click(@element).perform
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
        @element.attribute('value') || ''
      rescue WebDriver::Error::InvalidElementStateError
        ""
      end
    end

    def attribute_value(attribute_name)
      assert_exists
      @element.attribute attribute_name
    end

    def html
      assert_exists
      execute_atom(:getOuterHtml, @element).strip
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

    def fire_event(event_name)
      assert_exists
      event_name = event_name.to_s.sub(/^on/, '').downcase

      execute_atom :fireEvent, @element, event_name
    end

    def parent
      assert_exists

      e = execute_atom :getParentElement, @element

      if e.kind_of?(WebDriver::Element)
        Watir.element_class_for(e.tag_name.downcase).new(@parent, :element => e)
      end
    end

    #
    # @api private
    #

    def driver
      @parent.driver
    end

    #
    # @api private
    #

    def wd
      assert_exists
      @element
    end

    #
    # Returns true if this element is visible on the page
    #

    def visible?
      assert_exists
      @element.displayed?
    end

    #
    # Returns true if the element exists and is visible on the page
    #
    # @see Watir::Wait
    #

    def present?
      exists? && visible?
    end

    def style(property = nil)
      if property
        assert_exists
        @element.style property
      else
        attribute_value("style").to_s.strip
      end
    end

    def run_checkers
      @parent.run_checkers
    end

    #
    # Cast this Element instance to a more specific subtype.
    #
    # Example:
    #
    #   browser.element(:xpath => "//input[@type='submit']").to_subtype #=> #<Watir::Button>
    #

    def to_subtype
      elem = wd()
      tag_name = elem.tag_name.downcase

      klass = nil

      if tag_name == "input"
        klass = case elem.attribute(:type)
          when *Button::VALID_TYPES
            Button
          when 'checkbox'
            CheckBox
          when 'radio'
            Radio
          when 'file'
            FileField
          else
            TextField
          end
      else
        klass = Watir.element_class_for(tag_name)
      end

      klass.new(@parent, :element => elem)
    end

  protected

    def assert_exists
      if @element and not Watir.always_locate?
        return
      end

      @element = (@selector[:element] || locate)

      unless @element
        raise UnknownObjectException, "unable to locate element, using #{selector_string}"
      end
    end

    def browser
      @parent.browser
    end

    def reset!
      @parent.reset!
      @element = nil
    end

    def locate
      @parent.assert_exists
      locator_class.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

  private

    def locator_class
      ElementLocator
    end

    def selector_string
      @selector.inspect
    end

    def attribute?(attribute)
      assert_exists
      !!execute_atom(:getAttribute, @element, attribute.to_s.downcase)
    end

    def assert_enabled
      raise ObjectDisabledException, "object is disabled #{selector_string}" unless @element.enabled?
    end

    def assert_writable
      assert_enabled
      raise ObjectReadOnlyException if respond_to?(:readonly?) && readonly?
    end

    def method_missing(meth, *args, &blk)
      method = meth.to_s
      if method =~ /^data_(.+)$/
        attribute_value(method.gsub(/_/, '-'), *args)
      else
        super
      end
    end

  end # Element
end # Watir
