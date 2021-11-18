module Watir
  #
  # Base class for HTML elements.
  #

  class Element
    extend AttributeHelper

    include Exception
    include Container
    include Waitable
    include Adjacent
    include JSExecution
    include Locators::ClassHelpers
    include Scrolling

    attr_accessor :keyword
    attr_reader :selector

    # https://www.w3.org/TR/html52/single-page.html#casesensitivity
    CASE_INSENSITIVE_ATTRIBUTES = %i[accept accept_charset align alink axis
                                     bgcolor charset checked clear codetype
                                     color compact declare defer dir direction
                                     disabled enctype face frame hreflang
                                     http_equiv lang language link media
                                     method multiple nohref noresize noshade
                                     nowrap readonly rel rev rules scope
                                     scrolling selected shape target text
                                     type valign valuetype vlink].freeze

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

      raise ArgumentError, "invalid argument: #{selector.inspect}" unless selector.is_a? Hash

      selector[:index] = 0 if selector.empty?
      @element = selector.delete(:element)

      selector = {} if @element && !(selector.keys - [:tag_name]).empty?

      @selector = selector

      build unless @element
    end

    #
    # Returns true if element exists.
    # Checking for staleness is deprecated
    #
    # @return [Boolean]
    #

    def exists?
      if located? && stale?
        reset!
      elsif located?
        return true
      end

      assert_exists
      true
    rescue UnknownObjectException, UnknownFrameException
      false
    end
    alias exist? exists?

    def inspect
      string = "#<#{self.class}: "
      string << "keyword: #{keyword} " if keyword
      string << "located: #{located?}; "
      string << if @selector.empty?
                  '{element: (selenium element)}'
                else
                  selector_string
                end
      string << '>'
      string
    end

    #
    # Returns true if two elements are equal.
    #
    # TODO: Address how this is affected by stale elements
    # TODO: Address how this is affected by HTMLElement vs subclass
    # TODO: Address how this is affected by a non-located element
    #
    # @example
    #   browser.text_field(name: "new_user_first_name") == browser.text_field(name: "new_user_first_name")
    #   #=> true
    #

    def ==(other)
      other.is_a?(self.class) && wd == other.wd
    end
    alias eql? ==

    def hash
      located? ? @element.hash : super
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
    # @param [:shift, :alt, :control, :command, :meta] modifiers to press while clicking.
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
    # Determines the correct action based on subtype and takes it.
    # Default is to click element
    #

    def set(*args)
      subtype = to_subtype
      if subtype.is_a?(Radio) && [String, Regexp].include?(args.first.class)
        RadioSet.new(@query_scope, selector).set(*args)
      elsif subtype.class.included_modules.include?(UserEditable) || subtype.public_methods(false).include?(:set)
        subtype.set(*args)
      elsif @content_editable || content_editable?
        @content_editable = true
        extend UserEditable
        set(*args)
      elsif args.empty? || args.first
        click(*args)
      end
    end

    #
    # Simulates JavaScript click event on element.
    #
    # @example Click an element
    #   browser.element(name: "new_user_button").click!
    #

    def click!
      fire_event :click
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
      element_call(:wait_for_present) do
        scroll.to
        driver.action.double_click(@element).perform
      end
      browser.after_hooks.run
    end

    #
    # Simulates JavaScript double click event on element.
    #
    # @example
    #   browser.element(name: "new_user_button").double_click!
    #

    def double_click!
      fire_event :dblclick
      browser.after_hooks.run
    end

    #
    # Right clicks the element, optionally while pressing the given modifier keys.
    # Note that support for holding a modifier key is currently experimental,
    # and may not work at all. Also, the browser support may vary.
    #
    # @example
    #   browser.element(name: "new_user_button").right_click
    #
    # @example Right click an element with shift key pressed
    #   browser.element(name: "new_user_button").right_click(:shift)
    #
    # @example Click an element with several modifier keys pressed
    #   browser.element(name: "new_user_button").right_click(:shift, :alt)
    #
    # @param [:shift, :alt, :control, :command, :meta] modifiers to press while right clicking.
    #

    def right_click(*modifiers)
      element_call(:wait_for_present) do
        scroll.to
        action = driver.action
        if modifiers.any?
          modifiers.each { |mod| action.key_down mod }
          action.context_click(@element)
          modifiers.each { |mod| action.key_up mod }
          action.perform
        else
          action.context_click(@element).perform
        end
      end

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
      element_call(:wait_for_present) do
        scroll.to
        driver.action.move_to(@element).perform
      end
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

      value = element_call(:wait_for_present) do
        scroll.to
        driver.action
              .drag_and_drop(@element, other.wd)
              .perform
      end
      browser.after_hooks.run
      value
    end

    #
    # Drag and drop this element by the given offsets.
    # Note that browser support may vary.
    #
    # @example
    #   browser.div(id: "draggable").drag_and_drop_by 100, 25
    #
    # @param [Integer] right_by
    # @param [Integer] down_by
    #

    def drag_and_drop_by(right_by, down_by)
      element_call(:wait_for_present) do
        scroll.to
        driver.action
              .drag_and_drop_by(@element, right_by, down_by)
              .perform
      end
    end

    #
    # Returns list of class values.
    #
    # @return [Array]
    #

    def classes
      class_name.split
    end

    #
    # Returns given attribute value of element.
    #
    # @example
    #   browser.a(id: "link_2").attribute_value "title"
    #   #=> "link_title_2"
    #
    # @param [String, ::Symbol] attribute_name
    # @return [String, nil]
    #

    def attribute_value(attribute_name)
      attribute_name = attribute_name.to_s.tr('_', '-') if attribute_name.is_a?(::Symbol)
      element_call { @element.attribute attribute_name }
    end
    alias attribute attribute_value

    #
    # Returns all attribute values. Attributes with special characters are returned as String,
    # rest are returned as a Symbol.
    #
    # @return [Hash]
    #
    # @example
    #   browser.pre(id: 'rspec').attribute_values
    #   #=> {class:'ruby', id: 'rspec' }
    #

    def attribute_values
      result = element_call { execute_js(:attributeValues, @element) }
      result.keys.each do |key|
        next unless key == key[/[a-zA-Z\-]*/]

        result[key.tr('-', '_').to_sym] = result.delete(key)
      end
      result
    end
    alias attributes attribute_values

    #
    # Returns list of all attributes. Attributes with special characters are returned as String,
    # rest are returned as a Symbol.
    #
    # @return [Array]
    #
    # @example
    #   browser.pre(id: 'rspec').attribute_list
    #   #=> [:class, :id]
    #

    def attribute_list
      attribute_values.keys
    end

    #
    # Sends sequence of keystrokes to element.
    #
    # @example
    #   browser.text_field(name: "new_user_first_name").send_keys "Watir", :return
    #
    # @param [String, Symbol] args
    #

    def send_keys(*args)
      element_call(:wait_for_writable) { @element.send_keys(*args) }
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
    # location of element (x, y)
    #
    # @example
    #   browser.button(name: "new_user_button").location
    #
    # @return [Selenium::WebDriver::Point]
    #

    def location
      element_call { @element.location }
    end

    #
    # size of element (width, height)
    #
    # @example
    #   browser.button(name: "new_user_button").size
    #
    # @return [Selenium::WebDriver::Dimension]
    #

    def size
      element_call { @element.size }
    end

    #
    # Get height of element
    #
    # @example
    #   browser.button(name: "new_user_button").height
    #
    # @return [Selenium::WebDriver::Dimension]
    #

    def height
      size['height']
    end

    #
    # Get width of element
    #
    # @example
    #   browser.button(name: "new_user_button").width
    #
    # @return [Selenium::WebDriver::Dimension]
    #

    def width
      size['width']
    end

    #
    # Get centre coordinates of element
    #
    # @example
    #   browser.button(name: "new_user_button").centre
    #
    # @return [Selenium::WebDriver::Point]
    #

    def center
      point = location
      dimensions = size
      Selenium::WebDriver::Point.new(point.x + (dimensions['width'] / 2),
                                     point.y + (dimensions['height'] / 2))
    end
    alias centre center

    #
    # @api private
    #

    def driver
      @query_scope.driver
    end

    #
    # Returns underlying Selenium object of the Watir Element
    #
    # @return [Selenium::WebDriver::Element]
    #

    def wd
      assert_exists
      @element
    end

    #
    # Returns shadow root of element
    #
    # @return [Watir::ShadowRoot]
    #

    def shadow_root
      ShadowRoot.new(self, {})
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
      assert_exists
      @element.displayed?
    rescue UnknownObjectException, UnknownFrameException
      false
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      reset!
      retry
    end
    alias visible? present?

    #
    # Returns true if the element's center point is covered by a non-descendant element.
    #
    # @return [Boolean]
    #

    def obscured?
      element_call do
        return true unless present?

        scroll.to
        execute_js(:elementObscured, self)
      end
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
        attribute_value('style').to_s.strip
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
      tag = tag_name
      klass = if tag == 'input'
                case attribute_value(:type)
                when 'checkbox'
                  CheckBox
                when 'radio'
                  Radio
                when 'file'
                  FileField
                when *Button::VALID_TYPES
                  Button
                else
                  TextField
                end
              else
                Watir.element_class_for(tag)
              end

      klass.new(@query_scope, @selector).tap { |el| el.cache = wd }
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
      raise Error, 'Can not check staleness of unused element' unless @element

      ensure_context
      stale_in_context?
    end

    def stale_in_context?
      @element.css_value('staleness_check') # any wire call will check for staleness
      false
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      true
    end

    def reset!
      @element = nil
    end

    #
    # @api private
    #

    def locate
      msg = 'Can not relocate a Watir element initialized by a Selenium element'
      raise LocatorException, msg if @selector.empty?

      ensure_context
      locate_in_context
      self
    end

    #
    # @api private
    #

    def build
      selector_builder.build(@selector.dup)
    end

    #
    # @api private
    #
    # Returns true if element has been previously located.
    #
    # @return [Boolean]
    #

    def located?
      !!@element
    end

    #
    # @api private
    #
    # Set the cached element. For use when element can be relocated with the provided selector.
    #

    def cache=(element)
      @element = element
    end

    #
    # @api private
    #

    def selector_string
      return @selector.inspect if @query_scope.is_a?(Browser)

      "#{@query_scope.selector_string} --> #{@selector.inspect}"
    end

    protected

    def wait_for_exists
      return if located? # Performance shortcut

      begin
        @query_scope.wait_for_exists unless @query_scope.is_a? Browser
        wait_until(element_reset: true, &:exists?)
      rescue Wait::TimeoutError
        msg = "timed out after #{Watir.default_timeout} seconds, waiting for #{inspect} to be located"
        raise unknown_exception, msg
      end
    end

    def wait_for_present
      return true if present?

      begin
        @query_scope.wait_for_present unless @query_scope.is_a? Browser
        wait_until(&:present?)
      rescue Wait::TimeoutError
        msg = "element located, but timed out after #{Watir.default_timeout} seconds, " \
              "waiting for #{inspect} to be present"
        raise unknown_exception, msg
      end
    end

    def wait_for_enabled
      wait_for_exists
      return unless [Input, Button, Select, Option].any? { |c| is_a? c } || @content_editable
      return if enabled?

      begin
        wait_until(&:enabled?)
      rescue Wait::TimeoutError
        raise_disabled
      end
    end

    def wait_for_writable
      wait_for_enabled

      return if !respond_to?(:readonly?) || !readonly?

      begin
        wait_until { !respond_to?(:readonly?) || !readonly? }
      rescue Wait::TimeoutError
        raise_writable
      end
    end

    # Locates if not previously found; does not check for staleness for performance reasons
    def assert_exists
      locate unless located?
      return if located?

      raise unknown_exception, "unable to locate element: #{inspect}"
    end

    def ensure_context
      if @query_scope.is_a?(Browser) || !@query_scope.located? && @query_scope.is_a?(IFrame)
        @query_scope.browser.locate
      elsif @query_scope.located? && @query_scope.stale?
        @query_scope.locate
      end
      @query_scope.switch_to! if @query_scope.is_a?(IFrame)
    end

    def locate_in_context
      @element = locator.locate(selector_builder.built)
    end

    private

    def unknown_exception
      UnknownObjectException
    end

    def raise_writable
      message = "element present and enabled, but timed out after #{Watir.default_timeout} seconds, " \
                "waiting for #{inspect} to not be readonly"
      raise ObjectReadOnlyException, message
    end

    def raise_disabled
      message = "element present, but timed out after #{Watir.default_timeout} seconds, " \
                "waiting for #{inspect} to be enabled"
      raise ObjectDisabledException, message
    end

    def raise_present
      message = "element located, but timed out after #{Watir.default_timeout} seconds, " \
                               "waiting for #{inspect} to be present"
      raise unknown_exception, message
    end

    def element_class
      self.class
    end

    def assert_enabled
      raise ObjectDisabledException, "object is disabled #{inspect}" unless element_call { @element.enabled? }
    end

    def assert_is_element(obj)
      raise TypeError, "expected Watir::Element, got #{obj.inspect}:#{obj.class}" unless obj.is_a? Element
    end

    # TODO: - this will get addressed with Watir::Executor implementation
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity:
    # rubocop:disable Metrics/PerceivedComplexity::
    def element_call(precondition = nil, &block)
      caller = caller_locations(1, 1)[0].label
      already_locked = browser.timer.locked?
      browser.timer = Wait::Timer.new(timeout: Watir.default_timeout) unless already_locked

      begin
        check_condition(precondition, caller)
        Watir.logger.debug "-> `Executing #{inspect}##{caller}`"
        yield
      rescue unknown_exception => e
        element_call(:wait_for_exists, &block) if precondition.nil?
        msg = e.message
        msg += '; Maybe look in an iframe?' if @query_scope.iframe.exists?
        custom_attributes = !defined?(@locator) || @locator.nil? ? [] : selector_builder.custom_attributes
        unless custom_attributes.empty?
          msg += "; Watir treated #{custom_attributes} as a non-HTML compliant attribute, ensure that was intended"
        end
        raise unknown_exception, msg
      rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::NoSuchElementError
        reset!
        retry
        # TODO: - InvalidElementStateError is deprecated, so no longer calling `raise_disabled`
        # need a better way to handle this
      rescue Selenium::WebDriver::Error::ElementNotInteractableError
        raise_present unless browser.timer.remaining_time.positive?
        raise_present unless %i[wait_for_present wait_for_enabled wait_for_writable].include?(precondition)
        retry
      rescue Selenium::WebDriver::Error::NoSuchWindowError
        raise NoMatchingWindowFoundException, 'browser window was closed'
      ensure
        Watir.logger.debug "<- `Completed #{inspect}##{caller}`"
        browser.timer.reset! unless already_locked
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def check_condition(condition, caller)
      Watir.logger.debug "<- `Verifying precondition #{inspect}##{condition} for #{caller}`"
      begin
        condition.nil? ? assert_exists : send(condition)
        Watir.logger.debug "<- `Verified precondition #{inspect}##{condition || 'assert_exists'}`"
      rescue unknown_exception
        raise unless condition.nil?

        Watir.logger.debug "<- `Unable to satisfy precondition #{inspect}##{condition}`"
        check_condition(:wait_for_exists, caller)
      end
    end

    def method_missing(meth, *args, &blk)
      method = meth.to_s
      if method =~ Locators::Element::SelectorBuilder::WILDCARD_ATTRIBUTE
        attribute_value(meth, *args)
      elsif UserEditable.instance_methods(false).include?(meth) && content_editable?
        @content_editable = true
        extend UserEditable
        send(meth, *args, &blk)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      meth.to_s =~ Locators::Element::SelectorBuilder::WILDCARD_ATTRIBUTE || super
    end
  end # Element
end # Watir
