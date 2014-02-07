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

    alias_method :attributes, :attribute_list

    #
    # YARD macro to generated friendly
    # documentation for attributes.
    #
    # @macro [attach] attribute
    #  @method $2
    #  @return [$1] value of $3 attribute
    #
    def attribute(type, method, attr)
      typed_attributes[type] << [method, attr]

      # we don't want to override methods like :text or :hash
      define_attribute(type, method, attr) unless IGNORED_ATTRIBUTES.include?(attr)
    end

    private

    def self.extended(klass)
      klass.class_eval do
        # undefine deprecated methods to use them for Element attributes
        [:id, :type].each { |m| undef_method m if method_defined? m }
      end
    end

    def define_attribute(type, name, attr)
      case type
      when 'String'
        define_string_attribute(name, attr)
      when 'Boolean'
        define_boolean_attribute(name, attr)
      when 'Fixnum'
        define_int_attribute(name, attr)
      when 'Float'
        define_float_attribute(name, attr)
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
        @element.attribute(aname.delete('?')) == "true"
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

  end # AttributeHelper
end # Watir
