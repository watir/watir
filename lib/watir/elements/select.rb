module Watir
  class Select < HTMLElement
    include Watir::Exception

    #
    # Clears all selected options.
    #

    def clear
      raise Error, "you can only clear multi-selects" unless multiple?

      selected_options.each(&:click)
    end

    #
    # Gets all the options in the select list
    #
    # @return [Watir::OptionCollection]
    #

    def options(*)
      element_call(:wait_for_present) { super }
    end

    #
    # Returns true if the select list has one or more options where text or label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @return [Boolean]
    #

    def include?(str_or_rx)
      option(text: str_or_rx).exist? || option(label: str_or_rx).exist?
    end

    #
    # Select the option whose text or label matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The text of the option selected. If multiple options match, returns the first match.
    #

    def select(str_or_rx)
      select_by str_or_rx
    end

    #
    # Select all options whose text or label matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The text of the first option selected.
    #

    def select_all(str_or_rx)
      select_all_by str_or_rx
    end

    #
    # Uses JavaScript to select the option whose text matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    #

    def select!(str_or_rx)
      select_by!(:text, str_or_rx, 'single')
    end

    #
    # Uses JavaScript to select all options whose text matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    #

    def select_all!(str_or_rx)
      select_by!(:text, str_or_rx, 'multiple')
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
      Watir.logger.deprecate '#select_value', "#select"
      select_by str_or_rx
    end

    #
    # Uses JavaScript to select the option whose value attribute matches the given string.
    #
    # @see +select+
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    #

    def select_value!(str_or_rx)
      select_by!(:value, str_or_rx, 'single')
    end

    #
    # Returns true if any of the selected options' text or label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::UnknownObjectException] if the options do not exist
    # @return [Boolean]
    #

    def selected?(str_or_rx)
      by_text = options(text: str_or_rx)
      return true if by_text.find(&:selected?)

      by_label = options(label: str_or_rx)
      return true if by_label.find(&:selected?)

      return false unless by_text.size + by_label.size == 0

      raise(UnknownObjectException, "Unable to locate option matching #{str_or_rx.inspect}")
    end

    #
    # Returns the value of the first selected option in the select list.
    # Returns nil if no option is selected.
    #
    # @return [String, nil]
    #

    def value
      option = selected_options.first
      option && option.value
    end

    #
    # Returns the text of the first selected option in the select list.
    # Returns nil if no option is selected.
    #
    # @return [String, nil]
    #

    def text
      option = selected_options.first
      option && option.text
    end

    # Returns an array of currently selected options.
    #
    # @return [Array<Watir::Option>]
    #

    def selected_options
      element_call { execute_js :selectedOptions, self }
    end

    private

    def select_by(str_or_rx)
      found = find_options(:value,str_or_rx)

      if found && found.size > 1
        Watir.logger.deprecate "Selecting Multiple Options with #select", "#select_all"
      end
      return select_matching(found) if found && found.any?
      raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
    end
    def select_by!(how, str_or_rx, number)
      if str_or_rx.is_a? Regexp
        js_rx = str_or_rx.inspect.sub('\\A','^').sub('\\Z','$').sub('\\z','$').sub(/^\//,'').sub(/\/[a-z]*$/,'').gsub(/\(\?#.+\)/, '').gsub(/\(\?-\w+:/,'(')
      else
        js_rx = str_or_rx
      end

      if how == :text
        execute_js(:selectOptionsText, self, js_rx, number)
      else
        execute_js(:selectOptionsValue, self, js_rx, number)
      end

      return if selected_options.map(&how).any? { |v| str_or_rx.is_a?(String) ?  v == str_or_rx : v =~ str_or_rx }
      raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
    end

    def select_all_by(str_or_rx)
      raise Error, "you can only use #select_all on multi-selects" unless multiple?
      found = find_options :text, str_or_rx

      return select_matching(found) if found
      raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
    end

    def find_options(how, str_or_rx)
      browser.wait_while do
        case str_or_rx
        when String, Numeric, Regexp
          @found = how == :value ? options(value: str_or_rx) : []
          @found = options(text: str_or_rx) if @found.empty?
          @found = options(label: str_or_rx) if @found.empty?
          @found.empty? && Watir.relaxed_locate?
        else
          raise TypeError, "expected String or Regexp, got #{str_or_rx.inspect}:#{str_or_rx.class}"
        end
      end
      return @found unless @found.empty?
      raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
    rescue Wait::TimeoutError
      raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
    end

    def select_matching(elements)
      elements = [elements.first] unless multiple?
      elements.each { |e| e.click unless e.selected? }
      elements.first.exist? ? elements.first.text : ''
    end

    def matches_regexp?(how, element, exp)
      case how
      when :text
        element.text =~ exp || element.label =~ exp
      when :value
        element.value =~ exp
      else
        raise Error, "unknown how: #{how.inspect}"
      end
    end
  end # Select

  module Container
    alias_method :select_list, :select
    alias_method :select_lists, :selects

    Watir.tag_to_class[:select_list] = Select
  end # Container
end # Watir
