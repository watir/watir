# encoding: utf-8
module Watir
  class SelectList < Select
    include Watir::Exception

    container_method  :select_list
    collection_method :select_lists

    def enabled?
      !disabled?
    end

    def clear
      assert_exists

      raise Error, "you can only clear multi-selects" unless multiple?

      options.each do |o|
        o.toggle if o.selected?
      end
    end

    def includes?(str_or_rx)
      assert_exists
      options.any? { |e| str_or_rx === e.text }
    end

    def select(str_or_rx)
        select_by :text, str_or_rx, multiple?
    end

    def select_value(str_or_rx)
      select_by :value, str_or_rx, multiple?
    end

    def selected?(str_or_rx)
      assert_exists
      matches = @element.find_elements(:tag_name, 'option').select { |e| str_or_rx === e.text || str_or_rx === e.attribute(:label) }

      if matches.empty?
        raise UnknownObjectException, "Unable to locate option matching #{str_or_rx.inspect}"
      end

      matches.any? { |e| e.selected? }
    end

    def value
      o = options.find { |e| e.selected? }
      return if o.nil?

      o.value
    end

    def selected_options
      assert_exists
      options.map { |e| e.text if e.selected? }.compact
    end

    private

    def select_by(how, str_or_rx, multiple)
      case str_or_rx
      when String
        select_by_string(how, str_or_rx, multiple)
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
        rescue WebDriver::Error::WebDriverError # should be more specific
          raise NoValueFoundException, "#{string.inspect} not found in select list"
        end

        e.select unless e.selected?
        e.text
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
        element.text
      end
    end

    def option_xpath_for(how, string)
      case how
      when :text
        "//option[normalize-space()=#{string.inspect} or @label=#{string.inspect}]"
      when :value
        "//option[@value=#{string.inspect}]"
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

  end # SelectList
end # Watir
