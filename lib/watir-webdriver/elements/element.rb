# encoding: utf-8

module Watir

  #
  # Base class for HTML elements.
  #

  class Element
    extend AttributeHelper

    include Exception
    include Container
    include EventuallyPresent

    #
    # temporarily add :id and :class_name manually since they're no longer specified in the HTML spec.
    #
    # @see http://html5.org/r/6605
    # @see http://html5.org/r/7174
    #
    # TODO: use IDL from DOM core - http://dvcs.w3.org/hg/domcore/raw-file/tip/Overview.html
    #
    attribute String, :id, :id
    attribute String, :class_name, :className

    def initialize(parent, selector)
      @parent   = parent
      @selector = selector
      @element  = nil

      unless @selector.kind_of? Hash
        raise ArgumentError, "invalid argument: #{selector.inspect}"
      end
    end

    #
    # Returns true if element exists.
    #
    # @return [Boolean]
    #

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

    #
    # Returns true if two elements are equal.
    #
    # @example
    #   browser.a(:id => "foo") == browser.a(:id => "foo")
    #   #=> true
    #

    def ==(other)
      return false unless other.kind_of? self.class

      assert_exists
      @element == other.wd
    end
    alias_method :eql?, :==

    def hash
      @element ? @element.hash : super
    end

    #
    # Returns the text of the element.
    #
    # @return [String]
    #

    def text
      assert_exists
      @element.text
    end

    #
    # Returns tag name of the element.
    #
    # @return [String]
    #

    def tag_name
      assert_exists
      @element.tag_name.downcase
    end

    #
    # Clicks the element, optionally while pressing the given modifier keys.
    # Note that support for holding a modifier key is currently experimental,
    # and may not work at all.
    #
    # @example Click an element
    #   element.click
    #
    # @example Click an element with shift key pressed
    #   element.click(:shift)
    #
    # @example Click an element with several modifier keys pressed
    #   element.click(:shift, :control)
    #
    # @param [:shift, :alt, :control, :command, :meta] Modifier key(s) to press while clicking.
    #

    def click(*modifiers)
      assert_exists
      assert_enabled

      if modifiers.any?
        assert_has_input_devices_for "click(#{modifiers.join ', '})"

        action = driver.action
        modifiers.each { |mod| action.key_down mod }
        action.click @element
        modifiers.each { |mod| action.key_up mod }

        action.perform
      else
        @element.click
      end

      run_checkers
    end

    #
    # Double clicks the element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.a(:id => "foo").double_click
    #

    def double_click
      assert_exists
      assert_has_input_devices_for :double_click

      driver.action.double_click(@element).perform
      run_checkers
    end

    #
    # Right clicks the element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.a(:id => "foo").right_click
    #

    def right_click
      assert_exists
      assert_has_input_devices_for :right_click

      driver.action.context_click(@element).perform
      run_checkers
    end

    #
    # Moves the mouse to the middle of this element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.a(:id => "foo").hover
    #

    def hover
      assert_exists
      assert_has_input_devices_for :hover

      driver.action.move_to(@element).perform
    end

    #
    # Drag and drop this element on to another element instance.
    # Note that browser support may vary.
    #
    # @example
    #    a = browser.div(:id => "draggable")
    #    b = browser.div(:id => "droppable")
    #    a.drag_and_drop_on b
    #

    def drag_and_drop_on(other)
      assert_is_element other
      assert_exists
      assert_has_input_devices_for :drag_and_drop_on

      driver.action.
             drag_and_drop(@element, other.wd).
             perform
    end

    #
    # Drag and drop this element by the given offsets.
    # Note that browser support may vary.
    #
    # @example
    #    browser.div(:id => "draggable").drag_and_drop_by 100, -200
    #
    # @param [Fixnum] right_by
    # @param [Fixnum] down_by
    #

    def drag_and_drop_by(right_by, down_by)
      assert_exists
      assert_has_input_devices_for :drag_and_drop_by

      driver.action.
             drag_and_drop_by(@element, right_by, down_by).
             perform
    end

    #
    # Flashes (change background color far a moment) element.
    #
    # @example
    #    browser.div(:id => "draggable").flash
    #

    def flash
      background_color = style("backgroundColor")
      element_color = driver.execute_script("arguments[0].style.backgroundColor", @element)

      10.times do |n|
        color = (n % 2 == 0) ? "red" : background_color
        driver.execute_script("arguments[0].style.backgroundColor = '#{color}'", @element)
      end

      driver.execute_script("arguments[0].style.backgroundColor = arguments[1]", @element, element_color)

      self
    end

    #
    # Returns value of the element.
    #
    # @return [String]
    #

    def value
      assert_exists

      begin
        @element.attribute('value') || ''
      rescue Selenium::WebDriver::Error::InvalidElementStateError
        ""
      end
    end

    #
    # Returns given attribute value of element.
    #
    # @example
    #   browser.a(:id => "foo").attribute_value "href"
    #   #=> "http://watir.com"
    #
    # @param [String] attribute_name
    # @return [String]
    #

    def attribute_value(attribute_name)
      assert_exists
      @element.attribute attribute_name
    end

    #
    # Returns outer (inner + element itself) HTML code of element.
    #
    # @example
    #   browser.div(:id => "foo").html
    #   #=> "<div id=\"foo\"><a>Click</a></div>"
    #
    # @return [String]
    #

    def outer_html
      assert_exists
      execute_atom(:getOuterHtml, @element).strip
    end

    alias_method :html, :outer_html

    #
    # Returns inner HTML code of element.
    #
    # @example
    #   browser.div(:id => "foo").html
    #   #=> "<a>Click</a>"
    #
    # @return [String]
    #

    def inner_html
      assert_exists
      execute_atom(:getInnerHtml, @element).strip
    end

    #
    # Sends sequence of keystrokes to element.
    #
    # @example
    #   browser.div(:id => "foo").send_keys "Watir", :return
    #
    # @param [String, Symbol] *args
    #

    def send_keys(*args)
      assert_exists
      @element.send_keys(*args)
    end

    #
    # Focuses element.
    # Note that Firefox queues focus events until the window actually has focus.
    #
    # @see http://code.google.com/p/selenium/issues/detail?id=157
    #

    def focus
      assert_exists
      driver.execute_script "return arguments[0].focus()", @element
    end

    #
    # Returns true if this element is focused.
    #
    # @return [Boolean]
    #

    def focused?
      assert_exists
      @element == driver.switch_to.active_element
    end

    #
    # Simulates JavaScript events on element.
    # Note that you may omit "on" from event name.
    #
    # @example
    #   browser.a(:id => "foo").fire_event :click
    #   browser.a(:id => "foo").fire_event "mousemove"
    #   browser.a(:id => "foo").fire_event "onmouseover"
    #
    # @param [String, Symbol] event_name
    #

    def fire_event(event_name)
      assert_exists
      event_name = event_name.to_s.sub(/^on/, '').downcase

      execute_atom :fireEvent, @element, event_name
    end

    #
    # Returns parent element of current element.
    #

    def parent
      assert_exists

      e = execute_atom :getParentElement, @element

      if e.kind_of?(Selenium::WebDriver::Element)
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
    # Returns true if this element is visible on the page.
    #
    # @return [Boolean]
    #

    def visible?
      assert_exists
      @element.displayed?
    end

    #
    # Returns true if the element exists and is visible on the page.
    #
    # @return [Boolean]
    # @see Watir::Wait
    #

    def present?
      exists? && visible?
    rescue Selenium::WebDriver::Error::ObsoleteElementError, UnknownObjectException
      # if the element disappears between the exists? and visible? calls,
      # consider it not present.
      false
    end

    #
    # Returns given style property of this element.
    #
    # @example
    #   browser.a(:id => "foo").style
    #   #=> "display: block"
    #   browser.a(:id => "foo").style "display"
    #   #=> "block"
    #
    # @param [String] property
    # @return [String]
    #

    def style(property = nil)
      if property
        assert_exists
        @element.style property
      else
        attribute_value("style").to_s.strip
      end
    end

    #
    # Runs checkers.
    #

    def run_checkers
      @parent.run_checkers
    end

    #
    # Cast this Element instance to a more specific subtype.
    #
    # @example
    #   browser.element(:xpath => "//input[@type='submit']").to_subtype
    #   #=> #<Watir::Button>
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

    #
    # Returns browser.
    #
    # @return [Watir::Browser]
    #

    def browser
      @parent.browser
    end

  protected

    def assert_exists
      if @element and not Watir.always_locate?
        assert_not_stale
        return
      end

      @element = (@selector[:element] || locate)

      unless @element
        raise UnknownObjectException, "unable to locate element, using #{selector_string}"
      end
    end

    def assert_not_stale
      @element.enabled? # do a staleness check - any wire call will do.
    rescue Selenium::WebDriver::Error::ObsoleteElementError => ex
      # don't cache a stale element - it will never come back
      @element = nil
      raise UnknownObjectException, "#{ex.message} - #{selector_string}"
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

      if respond_to?(:readonly?) && readonly?
        raise ObjectReadOnlyException, "object is read only #{selector_string}"
      end
    end

    def assert_has_input_devices_for(name)
      unless driver.kind_of? Selenium::WebDriver::DriverExtensions::HasInputDevices
        raise NotImplementedError, "#{self.class}##{name} is not supported by this driver"
      end
    end

    def assert_is_element(obj)
      unless obj.kind_of? Watir::Element
        raise TypeError, "execpted Watir::Element, got #{obj.inspect}:#{obj.class}"
      end
    end

    def method_missing(meth, *args, &blk)
      method = meth.to_s
      if method =~ ElementLocator::WILDCARD_ATTRIBUTE
        attribute_value(method.gsub(/_/, '-'), *args)
      else
        super
      end
    end

  end # Element
end # Watir
