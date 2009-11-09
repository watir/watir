module Watir
  class BaseElement
    include Exceptions

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
        case type
        when :string
          define_string_attribute(method_name_for(name), name)
        when :bool
          define_boolean_attribute(method_name_for(name) + '?', name)
        when :int
          define_int_attribute(method_name_for(name), name)
        else
          $stderr.puts "treating #{type.inspect} as string for now"
        end
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
          assert_exists
          klass.new(self, *args)
        end
      end

      def collection_method(name)
        # TODO: collection methods
      end

      def identifier(selector)
        default_selector.merge! selector
      end

      def default_selector
        @default_selector ||= {}
      end

      def method_name_for(attribute)
        case attribute
        when "class"
          :class_name
        else
          attribute.to_s
        end
      end
    end # class << self

    def initialize(parent, selector)
      raise TypeError, "expected Hash, got #{selector.inspect}" unless selector.kind_of?(Hash)

      @parent   = parent
      @selector = selector.merge(self.class.default_selector)
    end

    def exists?
      assert_exists
      true
    rescue UnknownObjectException
      false
    end
    alias_method :exist?, :exists?

    def text
      assert_exists
      @element.text
    end

    def click
      assert_exists
      assert_enabled
      @element.click
    end

    def value
      assert_exists
      @element.value
    end

    def attribute_value(attribute_name)
      assert_exists
      @element.attribute(attribute_name)
    end

    def html
      assert_exists

      # this would ideally be in WebDriver
      method = case driver.bridge.browser
               when :firefox
                 'textContent'
               when :internet_explorer
                 'outerHTML' # ??
               when :chrome
                 'innerHTML'
               when :remote
                 # hmm
                 raise NotImplementedError
               else
                 raise NotImplementedError
               end


      driver.execute_script("return arguments[0].#{method}", @element)
    end

    def driver
      @parent.driver
    end

    def element
      assert_exists
      @element
    end

    private

    #
    # @api private
    #

    def assert_exists
      begin
        @element ||= ElementLocator.new(@parent.driver, @selector).locate
      rescue WebDriver::Error::WebDriverError => wde
        @element = nil
      end

      unless @element
        raise UnknownObjectException, "Unable to locate element, using #{@selector.inspect}"
      end
    end

    def assert_enabled
      raise ObjectDisabledException unless @element.enabled?
    end

  end # BaseElement
end # Watir

