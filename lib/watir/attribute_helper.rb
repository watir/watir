module Watir
  #
  # @private
  #
  # Extended by Element, provides methods for defining attributes on the element classes.
  #

  module AttributeHelper
    class << self
      private

      def extended(klass)
        klass.class_eval do
          # undefine deprecated methods to use them for Element attributes
          %i[id type].each { |m| undef_method m if method_defined? m }
        end
      end
    end

    def inherit_attributes_from(kls)
      kls.typed_attributes.each do |type, attrs|
        attrs.each { |method, attr| attribute type, method, attr }
      end
    end

    def typed_attributes
      @typed_attributes ||= Hash.new { |hash, type| hash[type] = [] }
    end

    def attribute_list
      @attribute_list ||= (typed_attributes.values.flatten +
                           ancestors[1..-1].map { |e|
                             e.attribute_list if e.respond_to?(:attribute_list)
                           }.compact.flatten
                          ).uniq
    end

    alias attributes attribute_list

    #
    # YARD macro to generated friendly
    # documentation for attributes.
    #
    # @macro [attach] attribute
    #  @method $2
    #  @return [$1] value of $3 property
    #
    def attribute(type, method, attr)
      typed_attributes[type] << [method, attr]
      define_attribute(type, method, attr)
    end

    def define_attribute(type, name, attr)
      case type.to_s
      when 'Boolean'
        define_boolean_attribute(name, attr)
      when 'Integer'
        define_int_attribute(name, attr)
      when 'Float'
        define_float_attribute(name, attr)
      else
        define_string_attribute(name, attr)
      end
    end

    def define_string_attribute(mname, aname)
      define_method mname do
        attribute_value(aname).to_s
      end
    end

    def define_boolean_attribute(mname, aname)
      define_method mname do
        attribute_value(aname) == 'true'
      end
    end

    def define_int_attribute(mname, aname)
      define_method mname do
        value = attribute_value(aname)
        value && Integer(value)
      end
    end

    def define_float_attribute(mname, aname)
      define_method mname do
        value = attribute_value(aname)
        value = nil if value == 'NaN'
        value && Float(value)
      end
    end
  end # AttributeHelper
end # Watir
