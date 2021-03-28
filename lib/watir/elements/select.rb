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
      option(text: str_or_rx).exist? || option(label: str_or_rx).exist? || option(value: str_or_rx).exist?
    end

    #
    # Select the option whose text or label matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    # @return [String] The text of the option selected. If multiple options match, returns the first match.
    #

    def select(*str_or_rx, text: nil, value: nil, label: nil)
      key, value = parse_select_args(str_or_rx, text, value, label)

      if value.size > 1 || value.first.is_a?(Array)
        value.flatten.map { |v| select_all_by key, v }.first
      else
        select_matching([find_option(key, value.flatten.first)])
      end
    end
    alias set select

    #
    # Uses JavaScript to select the option whose text matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::NoValueFoundException] if the value does not exist.
    #

    def select!(*str_or_rx, text: nil, value: nil, label: nil)
      key, value = parse_select_args(str_or_rx, text, value, label)

      if value.size > 1 || value.first.is_a?(Array)
        value.flatten.map { |v| select_by! key, v, :multiple }.first
      else
        value.flatten.map { |v| select_by! key, v, :single }.first
      end
    end

    #
    # Returns true if any of the selected options' text or label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::UnknownObjectException] if the options do not exist
    # @return [Boolean]
    #

    def selected?(*str_or_rx, text: nil, value: nil, label: nil)
      key, value = parse_select_args(str_or_rx, text, value, label)

      find_option(key, value.first).selected?
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

    # TODO: What is default behavior without #first ?
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

    def parse_select_args(str_or_rx, text, value, label)
      selectors = {}
      selectors[:any] = str_or_rx unless str_or_rx.empty?
      selectors[:text] = Array[text] if text
      selectors[:value] = Array[value] if value
      selectors[:label] = Array[label] if label

      raise ArgumentError, "too many arguments used for Select#select: #{selectors}" if selectors.size > 1

      selectors.first
    end

    def select_by!(key, str_or_rx, number)
      str_or_rx = type_check(str_or_rx)

      js_rx = process_str_or_rx(str_or_rx)
      approaches = key == :any ? %w[Text Label Value] : [key.to_s.capitalize]

      approaches.each do |approach|
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

    def select_all_by(key, str_or_rx)
      raise Error, 'you can only use #select_all on multi-selects' unless multiple_select_list?

      select_matching(find_options(key, str_or_rx))
    end

    def find_option(key, str_or_rx)
      val = type_check(str_or_rx)

      option(key => val).wait_until(&:exists?)
    rescue Wait::TimeoutError
      raise_no_value_found(str_or_rx)
    end

    def find_options(key, str_or_rx)
      val = type_check(str_or_rx)

      options(key => val).wait_until(&:exists?)
    rescue Wait::TimeoutError
      raise_no_value_found(str_or_rx)
    end

    def type_check(str_or_rx)
      str_or_rx = str_or_rx.to_s if str_or_rx.is_a?(Numeric)
      return str_or_rx if [String, Regexp].any? { |k| str_or_rx.is_a?(k) }

      raise TypeError, "expected String, Numeric or Regexp, got #{str_or_rx.inspect}:#{str_or_rx.class}"
    end

    # TODO: Consider locating the Select List before throwing the exception
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
