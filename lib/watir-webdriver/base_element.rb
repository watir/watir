# encoding: utf-8

module Watir
  class BaseElement
    include Exception
    include Container
    include Selenium

    IGNORED_ATTRIBUTES = [:text, :hash]

    class << self
      attr_writer :default_selector

      def typed_attributes
        @typed_attributes ||= Hash.new { |hash, type| hash[type] = []  }
      end

      def attribute_list
        @attribute_list ||= (
          list = typed_attributes.values.flatten
          list += ancestors[1..-1].map do |e|
            e.attribute_list if e.respond_to?(:attribute_list)
          end.compact.flatten
        ).uniq
      end

      def attributes(attribute_map = nil)
        if attribute_map.nil?
          return attribute_list
        end

        add_attributes attribute_map

        attribute_map.each do |type, attribs|
          attribs.each do |name|
            # we don't want to override methods like :text or :hash
            next if IGNORED_ATTRIBUTES.include?(name)
            define_attribute(type, name)
          end
        end
      end

      def default_selector
        @default_selector ||= {}
      end

      private

      def inherited(klass)
        klass.default_selector = default_selector.dup
      end

      def define_attribute(type, name)
        method_name    = method_name_for(type, name)
        attribute_name = attribute_for_method(name)

        (@attributes ||= []) << attribute_name

        case type
        when :string
          define_string_attribute(method_name, attribute_name)
        when :bool
          define_boolean_attribute(method_name, attribute_name)
        when :int
          define_int_attribute(method_name, attribute_name)
        else
          # $stderr.puts "treating #{type.inspect} as string for now"
        end
      end

      def define_string_attribute(mname, aname)
        define_method mname do
          assert_exists
          rescue_no_match { @element.attribute(aname).to_s }
        end
      end

      def define_boolean_attribute(mname, aname)
        define_method mname do
          assert_exists
          rescue_no_match(false) { !!@element.attribute(aname) }
        end
      end

      def define_int_attribute(mname, aname)
        define_method mname do
          assert_exists
          rescue_no_match(-1) { @element.attribute(aname).to_i }
        end
      end

      def container_method(name)
        klass = self
        Container.add name do |*args|
          klass.new(self, *args)
        end
      end

      def collection_method(name)
        constant_name = "#{name.to_s.camel_case}Collection"
        return if Watir.const_defined?(constant_name)

        element_class = self
        klass = Watir.const_set(
          constant_name,
          Class.new(ElementCollection)
        )

        Container.add name do
          klass.new(self, element_class)
        end
      end

      def add_attributes(attributes)
        attributes.each do |type, attr_list|
          typed_attributes[type] += attr_list
        end
      end

      def identifier(selector)
        Watir.tag_to_class[selector[:tag_name]] = self
        default_selector.merge! selector
      end

      def method_name_for(type, attribute)
        # TODO: rethink this - this list could get pretty long...
        name = case attribute
               when :html_for
                 'for'
               when :col_span
                 'colspan'
               when :row_span
                 'rowspan'
               else
                 attribute.to_s
               end

        name << "?" if type == :bool

        name
      end

      def attribute_for_method(method)
        case method.to_sym
        when :class_name
          'class'
        when :html_for
          'for'
        when :read_only
          'readonly'
        else
          method.to_s
        end
      end
    end # class << self

    def initialize(parent, *selectors)
      @parent   = parent
      @selector = extract_selector(selectors).merge(self.class.default_selector)

      if @selector.has_key?(:element)
        @element = @selector[:element]
      end
    end

    def exists?
      assert_exists
      true
    rescue UnknownObjectException
      false
    end
    alias_method :exist?, :exists?

    def inspect
      if @selector.has_key?(:element)
        '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, '{:element=>(webdriver element)}']
      else
        '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, @selector.inspect]
      end
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
      assert_exists
      original_color = driver.execute_script("arguments[0].style.backgroundColor", @element)
      10.times do |n|
        color = (n % 2 == 0) ? "red" : original_color
        driver.execute_script("arguments[0].style.backgroundColor = '#{color}'", @element)
      end
    end

    def value
      assert_exists
      rescue_no_match { @element.value || "" }
    end

    def attribute_value(attribute_name)
      assert_exists
      # should rescue?
      @element.attribute attribute_name
    end

    def html
      assert_exists
      browserbot('getOuterHTML', @element).strip
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
        Watir.element_class_for(e.tag_name).new(@parent, :element, e)
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
        rescue_no_match { attribute_value "style" } || ''
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

  private

    def selector_string
      @selector.inspect
    end

    def attribute?(a)
      assert_exists
      rescue_no_match(false) { !!@element.attribute(a)  }
    end

    def locate
      @parent.assert_exists
      ElementLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

    def assert_enabled
      raise ObjectDisabledException, "object is disabled #{selector_string}" unless @element.enabled?
    end

    def assert_writable
      assert_enabled
      raise ObjectReadOnlyException if respond_to?(:readonly?) && readonly?
    end

    def rescue_no_match(returned = "", &blk)
      yield
    rescue WebDriver::Error::ElementNotEnabledError
      returned
    end

    def extract_selector(selectors)
      case selectors.size
      when 2
        { selectors[0] => selectors[1] }
      when 1
        unless selectors.first.is_a? Hash
          raise ArgumentError, "expected Hash or (:how, 'what')"
        end

        selectors.first
      else
        raise ArgumentError, "wrong number of arguments (#{selectors.size} for 2)"
      end
    end

  end # BaseElement
end # Watir
