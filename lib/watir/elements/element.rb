module Watir

  #
  # Base class for HTML elements.
  #

  class Element
    extend AttributeHelper

    include Exception
    include Container
    include EventuallyPresent
    include Waitable
    include Adjacent

    attr_accessor :keyword

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

    def initialize(query_scope, selector)
      @query_scope = query_scope

      unless selector.kind_of? Hash
        raise ArgumentError, "invalid argument: #{selector.inspect}"
      end

      @element = selector.delete(:element)
      @selector = selector
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
      string = "#<#{self.class}: "
      string << "keyword: #{keyword} " if keyword
      string << "located: #{!!@element}; "
      if @selector.empty?
        string << '{element: (selenium element)}'
      else
        string << selector_string
      end
      string << '>'
      string
    end

    #
    # Returns true if two elements are equal.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name") == browser.text_field(name: "new_user_first_name")
    #   #=> true
    #

    def ==(other)
      other.is_a?(self.class) && wd == other.wd
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
      element_call { @element.text }
    end

    #
    # Returns tag name of the element.
    #
    # @return [String]
    #

    def tag_name
      element_call { @element.tag_name.downcase }
    end

    #
    # Clicks the element, optionally while pressing the given modifier keys.
    # Note that support for holding a modifier key is currently experimental,
    # and may not work at all.
    #
    # @example Click an element
    #   browser.element(name: "new_user_button").click
    #
    # @example Click an element with shift key pressed
    #   browser.element(name: "new_user_button").click(:shift)
    #
    # @example Click an element with several modifier keys pressed
    #   browser.element(name: "new_user_button").click(:shift, :control)
    #
    # @param [:shift, :alt, :control, :command, :meta] Modifier key(s) to press while clicking.
    #

    def click(*modifiers)
      element_call(:wait_for_enabled) do
        if modifiers.any?
          action = driver.action
          modifiers.each { |mod| action.key_down mod }
          action.click @element
          modifiers.each { |mod| action.key_up mod }

          action.perform
        else
          @element.click
        end
      end

      browser.after_hooks.run
    end

    #
    # Double clicks the element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.element(name: "new_user_button").double_click
    #

    def double_click
      element_call(:wait_for_present) { driver.action.double_click(@element).perform }
      browser.after_hooks.run
    end

    #
    # Right clicks the element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.element(name: "new_user_button").right_click
    #

    def right_click
      element_call(:wait_for_present) { driver.action.context_click(@element).perform }
      browser.after_hooks.run
    end

    #
    # Moves the mouse to the middle of this element.
    # Note that browser support may vary.
    #
    # @example
    #   browser.element(name: "new_user_button").hover
    #

    def hover
      element_call(:wait_for_present) { driver.action.move_to(@element).perform }
    end

    #
    # Drag and drop this element on to another element instance.
    # Note that browser support may vary.
    #
    # @example
    #   a = browser.div(id: "draggable")
    #   b = browser.div(id: "droppable")
    #   a.drag_and_drop_on b
    #

    def drag_and_drop_on(other)
      assert_is_element other

      element_call(:wait_for_present) do
        driver.action.
               drag_and_drop(@element, other.wd).
               perform
      end
    end

    #
    # Drag and drop this element by the given offsets.
    # Note that browser support may vary.
    #
    # @example
    #   browser.div(id: "draggable").drag_and_drop_by 100, -200
    #
    # @param [Integer] right_by
    # @param [Integer] down_by
    #

    def drag_and_drop_by(right_by, down_by)
      element_call(:wait_for_present) do
        driver.action.
               drag_and_drop_by(@element, right_by, down_by).
               perform
      end
    end

    #
    # Flashes (change background color far a moment) element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").flash
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
      attribute_value('value') || ''
    rescue Selenium::WebDriver::Error::InvalidElementStateError
      ''
    end

    #
    # Returns given attribute value of element.
    #
    # @example
    #   browser.a(id: "link_2").attribute_value "title"
    #   #=> "link_title_2"
    #
    # @param [String] attribute_name
    # @return [String, nil]
    #

    def attribute_value(attribute_name)
      element_call { @element.attribute attribute_name }
    end

    #
    # Returns outer (inner + element itself) HTML code of element.
    #
    # @example
    #   browser.div(id: 'foo').outer_html
    #   #=> "<div id=\"foo\"><a href=\"#\">hello</a></div>"
    #
    # @return [String]
    #

    def outer_html
      element_call { execute_atom(:getOuterHtml, @element) }.strip
    end

    alias_method :html, :outer_html

    #
    # Returns inner HTML code of element.
    #
    # @example
    #   browser.div(id: 'foo').inner_html
    #   #=> "<a href=\"#\">hello</a>"
    #
    # @return [String]
    #

    def inner_html
      element_call { execute_atom(:getInnerHtml, @element) }.strip
    end

    #
    # Sends sequence of keystrokes to element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").send_keys "Watir", :return
    #
    # @param [String, Symbol] *args
    #

    def send_keys(*args)
      element_call(:wait_for_writable) { @element.send_keys(*args) }
    end

    #
    # Focuses element.
    # Note that Firefox queues focus events until the window actually has focus.
    #
    # @see http://code.google.com/p/selenium/issues/detail?id=157
    #

    def focus
      element_call { driver.execute_script "return arguments[0].focus()", @element }
    end

    #
    # Returns true if this element is focused.
    #
    # @return [Boolean]
    #

    def focused?
      element_call { @element == driver.switch_to.active_element }
    end

    #
    # Simulates JavaScript events on element.
    # Note that you may omit "on" from event name.
    #
    # @example
    #   browser.button(name: "new_user_button").fire_event :click
    #   browser.button(name: "new_user_button").fire_event "mousemove"
    #   browser.button(name: "new_user_button").fire_event "onmouseover"
    #
    # @param [String, Symbol] event_name
    #

    def fire_event(event_name)
      event_name = event_name.to_s.sub(/^on/, '').downcase

      element_call { execute_atom :fireEvent, @element, event_name }
    end

    #
    # @api private
    #

    def driver
      @query_scope.driver
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
    # Raises exception if element does not exist
    #
    # @return [Boolean]
    #

    def visible?
      element_call(:assert_exists) { @element.displayed? }
    end

    #
    # Returns true if this element is present and enabled on the page.
    #
    # @return [Boolean]
    # @see Watir::Wait
    #

    def enabled?
      element_call(:assert_exists) { @element.enabled? }
    end

    #
    # Returns true if the element exists and is visible on the page.
    # Returns false if element does not exist or exists but is not visible
    #
    # @return [Boolean]
    # @see Watir::Wait
    #

    def present?
      visible?
    rescue UnknownObjectException
      false
    end

    #
    # Returns given style property of this element.
    #
    # @example
    #   browser.button(value: "Delete").style           #=> "border: 4px solid red;"
    #   browser.button(value: "Delete").style("border") #=> "4px solid rgb(255, 0, 0)"
    #
    # @param [String] property
    # @return [String]
    #

    def style(property = nil)
      if property
        element_call { @element.style property }
      else
        attribute_value("style").to_s.strip
      end
    end

    #
    # Cast this Element instance to a more specific subtype.
    #
    # @example
    #   browser.element(xpath: "//input[@type='submit']").to_subtype
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

      klass.new(@query_scope, element: elem)
    end

    #
    # Returns browser.
    #
    # @return [Watir::Browser]
    #

    def browser
      @query_scope.browser
    end

    #
    # Returns true if a previously located element is no longer attached to DOM.
    #
    # @return [Boolean]
    # @see Watir::Wait
    #

    def stale?
      raise Watir::Exception::Error, "Can not check staleness of unused element" unless @element
      @element.enabled? # any wire call will check for staleness
      false
    rescue Selenium::WebDriver::Error::ObsoleteElementError
      true
    end

    def reset!
      @element = nil
    end

    protected

    def wait_for_exists
      return assert_exists unless Watir.relaxed_locate?
      return if exists? # Performance shortcut

      begin
        @query_scope.wait_for_exists
        wait_until(&:exists?)
      rescue Watir::Wait::TimeoutError
        unless Watir.default_timeout == 0
          message = "This code has slept for the duration of the default timeout "
          message << "waiting for an Element to exist. If the test is still passing, "
          message << "consider using Element#exists? instead of rescuing UnknownObjectException"
          warn message
        end
        raise unknown_exception, "timed out after #{Watir.default_timeout} seconds, "\
                                         "waiting for #{inspect} to be located"
      end
    end

    def wait_for_present
      return assert_exists unless Watir.relaxed_locate?

      wait_for_exists
      begin
        @query_scope.wait_for_present
        wait_until_present
      rescue Watir::Wait::TimeoutError => ex
        unless Watir.default_timeout == 0
          message = "This code has slept for the duration of the default timeout "
          message << "waiting for an Element to be present. If the test is still passing, "
          message << "consider using Element#exists? instead of rescuing UnknownObjectException"
          warn message
        end
        raise unknown_exception, "element located, but #{ex.message}"
      end
    end

    def wait_for_enabled
      return assert_enabled unless Watir.relaxed_locate?

      wait_for_present
      begin
        wait_until(&:enabled?)
      rescue Watir::Wait::TimeoutError
        message = "element present, but timed out after #{Watir.default_timeout} seconds, waiting for #{inspect} to be enabled"
        raise ObjectDisabledException, message
      end
    end

    def wait_for_writable
      return assert_writable unless Watir.relaxed_locate?

      wait_for_enabled
      begin
        wait_until { !respond_to?(:readonly?) || !readonly? }
      rescue Watir::Wait::TimeoutError
        message = "element present and enabled, but timed out after #{Watir.default_timeout} seconds, waiting for #{inspect} to not be readonly"
        raise ObjectReadOnlyException, message
      end
    end

    # Ensure that the element exists, making sure that it is not stale and located if necessary
    def assert_exists
      if @element && @selector.empty?
        ensure_context
        @element.reset! if stale?
      elsif @element && !stale?
        return
      else
        @element = locate
      end

      assert_element_found
    end

    def assert_element_found
      unless @element
        raise unknown_exception, "unable to locate element: #{inspect}"
      end
    end

    def locate
      ensure_context

      element_validator = element_validator_class.new
      selector_builder = selector_builder_class.new(@query_scope, @selector, self.class.attribute_list)
      locator = locator_class.new(@query_scope, @selector, selector_builder, element_validator)

      locator.locate
    end

    def selector_string
      return @selector.inspect if @query_scope.is_a?(Browser)
      "#{@query_scope.selector_string} --> #{@selector.inspect}"
    end

    private

    def unknown_exception
      Watir::Exception::UnknownObjectException
    end

    def locator_class
      Kernel.const_get("#{Watir.locator_namespace}::#{element_class_name}::Locator")
    rescue NameError
      Kernel.const_get("#{Watir.locator_namespace}::Element::Locator")
    end

    def element_validator_class
      Kernel.const_get("#{Watir.locator_namespace}::#{element_class_name}::Validator")
    rescue NameError
      Kernel.const_get("#{Watir.locator_namespace}::Element::Validator")
    end

    def selector_builder_class
      Kernel.const_get("#{Watir.locator_namespace}::#{element_class_name}::SelectorBuilder")
    rescue NameError
      Kernel.const_get("#{Watir.locator_namespace}::Element::SelectorBuilder")
    end

    def element_class_name
      self.class.name.split('::').last
    end

    # Ensure the driver is in the desired browser context
    def ensure_context
      @query_scope.is_a?(IFrame) ? @query_scope.switch_to! : @query_scope.assert_exists
    end

    def attribute?(attribute_name)
      !attribute_value(attribute_name).nil?
    end

    def assert_enabled
      unless element_call { @element.enabled? }
        raise ObjectDisabledException, "object is disabled #{inspect}"
      end
    end

    def assert_writable
      assert_enabled

      if respond_to?(:readonly?) && readonly?
        raise ObjectReadOnlyException, "object is read only #{inspect}"
      end
    end

    def assert_is_element(obj)
      unless obj.kind_of? Watir::Element
        raise TypeError, "execpted Watir::Element, got #{obj.inspect}:#{obj.class}"
      end
    end

    def element_call(exist_check = :wait_for_exists)
      already_locked = Wait.timer.locked?
      Wait.timer = Wait::Timer.new(timeout: Watir.default_timeout) unless already_locked
      begin
        send exist_check
        yield
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        retry
      rescue Selenium::WebDriver::Error::UnknownError => ex
          # Chromedriver and Legacy Firefox Driver throw UnknownError when element not clickable
          raise unless ex.message =~ /Element is not clickable at point/
          retry
      ensure
        Wait.timer.reset! unless already_locked
      end
    end

    def method_missing(meth, *args, &blk)
      method = meth.to_s
      if method =~ Locators::Element::SelectorBuilder::WILDCARD_ATTRIBUTE
        attribute_value(method.tr('_', '-'), *args)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      Locators::Element::SelectorBuilder::WILDCARD_ATTRIBUTE === meth.to_s || super
    end

  end # Element
end # Watir
