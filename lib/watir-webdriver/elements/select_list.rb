# encoding: utf-8
module Watir
  class Select < HTMLElement
    include Watir::Exception

    #
    # Returns true if this element is enabled
    #
    # @return [Boolean]
    #

    def enabled?
      !disabled?
    end

    #
    # Clear all selected options
    #

    def clear
      assert_exists

      raise Error, "you can only clear multi-selects" unless multiple?

      options.each do |o|
        o.toggle if o.selected?
      end
    end

    def options
      assert_exists
      super
    end

    #
    # Returns true if the select list has one or more options where text or label matches the given value.
    #
    # @param [String, Regexp] value A value.
    # @return [Boolean]
    #

    def include?(str_or_rx)
      assert_exists
      # TODO: optimize similar to selected?
      options.any? { |e| str_or_rx === e.text }
    end
    alias_method :includes?, :include?

    #
    # Select the option(s) whose text or label matches the given string.
    # If this is a multi-select and several options match the value given, all will be selected.
    #
    # @param [String, Regexp] value A value.
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The text of the option selected. If multiple options match, returns the first match.
    #

    def select(str_or_rx)
      select_by :text, str_or_rx, multiple?
    end

    #
    # Selects the option(s) whose value attribute matches the given string.
    #
    # @see +select+
    #
    # @param [String, Regexp] value A value.
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The option selected. If multiple options match, returns the first match
    #

    def select_value(str_or_rx)
      select_by :value, str_or_rx, multiple?
    end

    #
    # Returns true if any of the selected options' text or label match the given value.
    #
    # @param [String, Regexp] value A value.
    # @raise [Watir::Exception::UnknownObjectException] if the value does not exist.
    # @return [Boolean]
    #

    def selected?(str_or_rx)
      assert_exists
      matches = @element.find_elements(:tag_name, 'option').select { |e| str_or_rx === e.text || str_or_rx === e.attribute(:label) }

      if matches.empty?
        raise UnknownObjectException, "Unable to locate option matching #{str_or_rx.inspect}"
      end

      matches.any? { |e| e.selected? }
    end

    #
    # Returns the value of the first selected option in the select list.
    # Returns nil if no option is selected.
    #
    # @return [String, nil]
    #

    def value
      o = options.find { |e| e.selected? } || return
      o.value
    end


    #
    # @return [Array<String>] An array of strings representing the text value of the currently selected options.
    #

    def selected_options
      assert_exists
      options.map { |e| e.text if e.selected? }.compact
    end

    private

    def select_by(how, str_or_rx, multiple)
      case str_or_rx
      when String, Numeric
        select_by_string(how, str_or_rx.to_s, multiple)
      when Regexp
        select_by_regexp(how, str_or_rx, multiple)
      else
        raise ArgumentError, "expected String or Regexp, got #{str_or_rx.inspect}:#{str_or_rx.class}"
      end
    end

    def select_by_string(how, string, multiple)
      xpath = option_xpath_for(how, string)
      if multiple
        elements = @element.find_elements(:xpath, xpath)

        if elements.empty?
          raise NoValueFoundException, "#{string.inspect} not found in select list"
        end

        elements.each { |e| e.select unless e.selected? }
        elements.first.text
      else
        begin
          e = @element.find_element(:xpath, xpath)
        rescue WebDriver::Error::NoSuchElementError
          raise NoValueFoundException, "#{string.inspect} not found in select list"
        end

        e.select unless e.selected?

        safe_text(e)
      end
    end

    def select_by_regexp(how, exp, multiple)
      elements = @element.find_elements(:tag_name, 'option')
      if elements.empty?
        raise NoValueFoundException, "no options in select list"
      end

      if multiple
        found = elements.select do |e|
          next unless matches_regexp?(how, e, exp)
          e.select unless e.selected?
          true
        end

        if found.empty?
          raise NoValueFoundException, "#{exp.inspect} not found in select list"
        end

        found.first.text
      else
        element = elements.find { |e| matches_regexp?(how, e, exp) }
        unless element
          raise NoValueFoundException, "#{exp.inspect} not found in select list"
        end

        element.select unless element.selected?

        safe_text(element)
      end
    end

    def option_xpath_for(how, string)
      case how
      when :text
        ".//option[normalize-space()='#{string}' or @label='#{string}']"
      when :value
        ".//option[@value='#{string}']"
      else
        raise Error, "unknown how: #{how.inspect}"
      end
    end

    def matches_regexp?(how, element, exp)
      case how
      when :text
        element.text =~ exp || element.attribute(:label) =~ exp
      when :value
        element.attribute(:value) =~ exp
      else
        raise Error, "unknown how: #{how.inspect}"
      end
    end

    def safe_text(element)
      element.text
    rescue Selenium::WebDriver::Error::ObsoleteElementError
      # guard for scenario where selecting the element changes the page, making our element obsolete

      ''
    end

  end # Select
end # Watir
