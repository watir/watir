module Watir
  class Select < HTMLElement
    #
    # Clears all selected options.
    #

    def clear
      raise Exception::Error, 'you can only clear multi-selects' unless multiple_select_list?

      selected_options.each(&:click)
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

    def select(*str_or_rx)
      value = str_or_rx.flatten
      if value.size > 1 && multiple_select_list?
        value.map { |v| select_all_by v }.first
      elsif value.size > 1
        raise Error, 'too many arguments used for #select, use #select_all'
      else
        select_matching([find_option(value.first)])
      end
    end

    #
    # Select all options whose text or label matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The text of the first option selected.
    #

    def select_all(*str_or_rx)
      raise Error, 'you can only use #select_all on multi-selects' unless multiple_select_list?

      str_or_rx.flatten.map { |v| select_all_by v }.first
    end

    #
    # Uses JavaScript to select the option whose text matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    #

    def select!(*str_or_rx)
      val = str_or_rx.flatten
      return select_all!(val) if val.size > 1 && multiple_select_list?

      select_by!(val.first, :single)
    end

    #
    # Uses JavaScript to select all options whose text matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    #

    def select_all!(*str_or_rx)
      str_or_rx.flatten.map { |v| select_by!(v, :multiple) }.first
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

      return false unless (by_text.size + by_label.size).zero?

      raise(UnknownObjectException, "Unable to locate option matching #{str_or_rx.inspect}")
    end

    #
    # Returns the value of the first selected option in the select list.
    # Returns nil if no option is selected.
    #
    # @return [String, nil]
    #

    def value
      selected_options.first&.value
    end

    #
    # Returns the text of the first selected option in the select list.
    # Returns nil if no option is selected.
    #
    # @return [String, nil]
    #

    def text
      selected_options.first&.text
    end

    # Returns an array of currently selected options.
    #
    # @return [Array<Watir::Option>]
    #

    def selected_options
      element_call { execute_js :selectedOptions, self }
    end

    private

    def multiple_select_list?
      @multiple_select = @multiple_select.nil? ? multiple? : @multiple_select
    end

    def select_by!(str_or_rx, number)
      str_or_rx = type_check(str_or_rx)

      js_rx = process_str_or_rx(str_or_rx)

      %w[Text Label Value].each do |approach|
        element_call { execute_js("selectOptions#{approach}", self, js_rx, number.to_s) }
        return selected_options.first.text if matching_option?(approach.downcase, str_or_rx)
      end

      raise_no_value_found(str_or_rx)
    end

    def process_str_or_rx(str_or_rx)
      case str_or_rx
      when String
        "^#{str_or_rx}$"
      when Regexp
        str_or_rx.inspect.sub('\\A', '^')
                 .sub('\\Z', '$')
                 .sub('\\z', '$')
                 .sub(%r{^/}, '')
                 .sub(%r{/[a-z]*$}, '')
                 .gsub(/\(\?#.+\)/, '')
                 .gsub(/\(\?-\w+:/, '(')
      else
        raise TypeError, "expected String or Regexp, got #{str_or_rx.inspect}:#{str_or_rx.class}"
      end
    end

    def matching_option?(how, what)
      selected_options.each do |opt|
        value = opt.send(how)
        next unless what.is_a?(String) ? value == what : value =~ what
        return true if opt.enabled?

        raise ObjectDisabledException, "option matching #{what} by #{how} on #{inspect} is disabled"
      end
      false
    end

    def select_all_by(str_or_rx)
      val = type_check(str_or_rx)

      select_matching(find_options(val))
    end

    def find_option(str_or_rx)
      val = type_check(str_or_rx)

      option(any: val).wait_until(&:exists?)
    rescue Wait::TimeoutError
      raise_no_value_found(val)
    end

    def find_options(str_or_rx)
      val = type_check(str_or_rx)

      opts = options(any: val)
      wait_until { opts.size.positive? }
      opts
    rescue Wait::TimeoutError
      raise_no_value_found(val)
    end

    def type_check(str_or_rx)
      str_or_rx = str_or_rx.to_s if str_or_rx.is_a?(Numeric)
      msg = "expected String, Numeric or Regexp, got #{str_or_rx.inspect}:#{str_or_rx.class}"
      raise TypeError, msg unless [String, Regexp].any? { |k| str_or_rx.is_a?(k) }

      str_or_rx
    end

    def raise_no_value_found(str_or_rx)
      raise NoValueFoundException, "#{str_or_rx.inspect} not found in #{inspect}"
    end

    def select_matching(elements)
      elements.each { |e| e.click unless e.selected? }
      elements.first.exists? ? elements.first.text : ''
    end
  end # Select

  module Container
    alias select_list select
    alias select_lists selects

    Watir.tag_to_class[:select_list] = Select
  end # Container
end # Watir
