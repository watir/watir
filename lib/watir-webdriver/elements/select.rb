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
    # Clears all selected options.
    #

    def clear
      assert_exists

      raise Error, "you can only clear multi-selects" unless multiple?

      options.each do |o|
        o.click if o.selected?
      end
    end

    #
    # Gets all the options in the select list
    #
    # @return [Watir::OptionCollection]
    #

    def options
      assert_exists
      super
    end

    #
    # Returns true if the select list has one or more options where text or label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @return [Boolean]
    #

    def include?(str_or_rx)
      assert_exists
      # TODO: optimize similar to selected?
      options.any? { |e| str_or_rx === e.text }
    end

    #
    # Select the option(s) whose text or label matches the given string.
    # If this is a multi-select and several options match the value given, all will be selected.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The text of the option selected. If multiple options match, returns the first match.
    #

    def select(str_or_rx)
      select_by :text, str_or_rx
    end

    #
    # Selects the option(s) whose value attribute matches the given string.
    #
    # @see +select+
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The option selected. If multiple options match, returns the first match
    #

    def select_value(str_or_rx)
      select_by :value, str_or_rx
    end

    #
    # Returns true if any of the selected options' text or label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::UnknownObjectException] if the options do not exist
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
    # Returns an array of currently selected options.
    #
    # @return [Array<Watir::Option>]
    #

    def selected_options
      assert_exists
      options.select { |e| e.selected? }
    end

    private

    def select_by(how, str_or_rx)
      assert_exists

      case str_or_rx
      when String, Numeric
        select_by_string(how, str_or_rx.to_s)
      when Regexp
        select_by_regexp(how, str_or_rx)
      else
        raise TypeError, "expected String or Regexp, got #{str_or_rx.inspect}:#{str_or_rx.class}"
      end
    end

    def select_by_string(how, string)
      xpath = option_xpath_for(how, string)

      if multiple?
        elements = @element.find_elements(:xpath, xpath)
        no_value_found(string) if elements.empty?

        elements.each { |e| e.click unless e.selected? }
        elements.first.text
      else
        begin
          e = @element.find_element(:xpath, xpath)
        rescue Selenium::WebDriver::Error::NoSuchElementError
          no_value_found(string)
        end

        e.click unless e.selected?

        safe_text(e)
      end
    end

    def select_by_regexp(how, exp)
      elements = @element.find_elements(:tag_name, 'option')
      no_value_found(nil, "no options in select list") if elements.empty?

      if multiple?
        found = elements.select do |e|
          next unless matches_regexp?(how, e, exp)
          e.click unless e.selected?
          true
        end

        no_value_found(exp) if found.empty?

        found.first.text
      else
        element = elements.find { |e| matches_regexp?(how, e, exp) }
        no_value_found(exp) unless element

        element.click unless element.selected?

        safe_text(element)
      end
    end

    def option_xpath_for(how, string)
      string = XpathSupport.escape string

      case how
      when :text
        ".//option[normalize-space()=#{string} or @label=#{string}]"
      when :value
        ".//option[@value=#{string}]"
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
    rescue Selenium::WebDriver::Error::ObsoleteElementError, Selenium::WebDriver::Error::UnhandledAlertError
      # guard for scenario where selecting the element changes the page, making our element obsolete

      ''
    end

    def no_value_found(arg, msg = nil)
      raise NoValueFoundException, msg || "#{arg.inspect} not found in select list"
    end
  end # Select

  module Container
    alias_method :select_list,  :select
    alias_method :select_lists, :selects

    Watir.tag_to_class[:select_list] = Select
  end # Container
end # Watir
