module Watir
  class ElementLocator
    include Watir::Exceptions

    def initialize(driver, selector)
      @driver   = driver
      @selector = selector.dup
    end

    def locate
      @tag_name = @selector.delete(:tag_name) || raise("no tag name?")
      @tag_name = @tag_name.to_s

      if @selector.size == 1
        single_selector_locate
      else
        multi_selector_locate
      end
    end

    def single_selector_locate
      how, what = @selector.shift

      check_type what

      case how.to_sym
      when :id
        element_by_id what
      when :name
        element_by_name what
      else
        raise UnknownWayOfFindingObjectException
      end
    end

    def multi_selector_locate
      raise NotImplementedError
    end

    def element_by_id(what)
      if what.kind_of? String
        element = @driver.find_element(:id, what) # TODO: rescue?
        return element if element.tag_name == @tag_name
      end

      if what.kind_of?(Regexp)
        elements = @driver.find_elements(:tag_name, @tag_name).find { |e| what =~ e.attribute(:id) }
      else
        @driver.find_elements(:id, what).find { |e| e.tag_name == @tag_name }
      end
    end

    def element_by_name(what)
      if what.kind_of?(String)
        element = @driver.find_element(:name, what) # TODO: rescue?
        return element if element.tag_name == @tag_name
      end

      if what.kind_of?(Regexp)
        elements = @driver.find_elements(:tag_name, @tag_name).find { |e| what =~ e.attribute(:name) }
      else
        @driver.find_elements(:name, what).find { |e| e.tag_name == @tag_name }
      end
    end

    def check_type(what)
      unless [String, Regexp].any? { |t| what.kind_of? t }
        raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
      end
    end

  end # ElementLocator
end # Watir
