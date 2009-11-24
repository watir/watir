module Watir
  class BaseElement
    include Exceptions
    include Container
    include Selenium

    class << self

      def inherited(klass)
        klass.instance_variable_set("@default_selector", default_selector.dup)
      end

      def attributes(attribute_map)
        attribute_map.each do |type, attribs|
          attribs.each { |name| define_attribute(type, name) }
        end
      end

      def define_attribute(type, name)
        attribute = attribute_for_method(name)

        case type
        when :string
          define_string_attribute(name, attribute)
        when :bool
          define_boolean_attribute("#{method_name_for(name)}?", attribute)
        when :int
          define_int_attribute(name, attribute)
        else
          # $stderr.puts "treating #{type.inspect} as string for now"
        end

        attribute_list << attribute
      end

      def define_string_attribute(mname, aname)
        define_method mname do
          assert_exists
          @element.attribute(aname).to_s rescue "" # TODO: rescue specific exception
        end
      end

      def define_boolean_attribute(mname, aname)
        define_method mname do
          assert_exists
          !!@element.attribute(aname) rescue false # TODO: rescue specific exception
        end
      end

      def define_int_attribute(mname, aname)
        define_method mname do
          assert_exists
          @element.attribute(aname).to_i rescue "" # TODO: rescue specific exception
        end
      end

      def container_method(name)
        klass = self
        Container.add name do |*args|
          klass.new(self, *args)
        end
      end

      def collection_method(name)
        element_class = self
        klass = Watir.const_set(
          "#{name.to_s.camel_case}Collection",
          Class.new(ElementCollection)
        )

        Container.add name do
          klass.new(self, element_class)
        end
      end

      def identifier(selector)
        Watir.tag_to_class[selector[:tag_name]] = self
        default_selector.merge! selector
      end

      def default_selector
        @default_selector ||= {}
      end

      def attribute_list
        @attribute_list ||= []
      end

      def method_name_for(attribute)
        attribute.to_s
      end

      def attribute_for_method(method)
        case method
        when :class_name
          'class'
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
      '#<%s:0x%x located=%s selector=%s>' % [self.class, hash*2, !!@element, @selector.inspect]
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

    def value
      assert_exists
      @element.value rescue "" # TODO: specific exception
    end

    def attribute_value(attribute_name)
      assert_exists
      @element.attribute(attribute_name)
    end

    def html
      assert_exists

      driver.execute_script(<<-JAVASCRIPT, @element)
        var e = arguments[0];
        if(e.outerHTML) {
          return e.outerHTML;
        } else {
          return e.innerHTML;
        }
      JAVASCRIPT
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
      @element.visible?
    end

    private

    #
    # @api private
    #

    def assert_exists
      @element ||= locate

      unless @element
        raise UnknownObjectException, "Unable to locate element, using #{@selector.inspect}"
      end
    end

    def locate
      ElementLocator.new(@parent.driver, @selector).locate
    rescue WebDriver::Error::WebDriverError => wde
      nil
    end

    def assert_enabled
      raise ObjectDisabledException unless @element.enabled?
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

    def run_checkers
      @parent.run_checkers
    end

  end # BaseElement
end # Watir
