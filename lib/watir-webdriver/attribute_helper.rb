module Watir

  #
  # @private
  #
  # Extended by Element, provides methods for defining attributes on the element classes.
  #

  module AttributeHelper

    IGNORED_ATTRIBUTES = [:text, :hash]

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
      attribute_map or return attribute_list

      add_attributes attribute_map

      attribute_map.each do |type, attribs|
        attribs.each do |name|
          # we don't want to override methods like :text or :hash
          next if IGNORED_ATTRIBUTES.include?(name)
          define_attribute(type, name)
        end
      end
    end

    private

    def self.extended(klass)
      klass.class_eval do
        # undefine deprecated methods to use them for Element attributes
        [:id, :type].each { |m| undef_method m if method_defined? m }
      end
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
      when :float
        define_float_attribute(method_name, attribute_name)
      else
        # $stderr.puts "treating #{type.inspect} as string for now"
      end
    end

    def define_string_attribute(mname, aname)
      define_method mname do
        assert_exists
        @element.attribute(aname).to_s
      end
    end

    def define_boolean_attribute(mname, aname)
      define_method mname do
        assert_exists
        @element.attribute(aname) == "true"
      end
    end

    def define_int_attribute(mname, aname)
      define_method mname do
        assert_exists
        value = @element.attribute(aname)
        value && Integer(value)
      end
    end

    def define_float_attribute(mname, aname)
      define_method mname do
        assert_exists
        value = @element.attribute(aname)
        value && Float(value)
      end
    end

    def add_attributes(attributes)
      attributes.each do |type, attr_list|
        typed_attributes[type] += attr_list
      end
    end

    def method_name_for(type, attribute)
      # http://github.com/jarib/watir-webdriver/issues/issue/26
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
      # http://github.com/jarib/watir-webdriver/issues/issue/26

      case method.to_sym
      when :class_name
        'class'
      when :html_for
        'for'
      when :read_only
        'readonly'
      when :http_equiv
        'http-equiv'
      when :col_span
        'colspan'
      when :row_span
        'rowspan'
      else
        method.to_s
      end
    end

  end # AttributeHelper
end # Watir
