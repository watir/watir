# encoding: utf-8
module Watir
  class ElementLocator
    include Watir::Exception
    include Selenium

    WD_FINDERS =  [ :class, :class_name, :id, :link_text, :link,
                    :partial_link_text, :name, :tag_name, :xpath ]

    def initialize(wd, selector)
      @wd   = wd
      @selector = selector.dup
    end

    def locate
      # short-circuit if :id is given
      if e = by_id
        return e
      end

      if @selector.size == 1
        find_first_by_one
      else
        find_first_by_multiple
      end
    rescue WebDriver::Error::WebDriverError => wde
      nil
    end

    def locate_all
      if @selector.size == 1
        find_all_by_one
      else
        find_all_by_multiple
      end
    end

    def find_first_by_one
      how, what = @selector.shift
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_first_by(how, what)
      else
        raise NotImplementedError, "find first by attribute/other"
      end
    end

    def find_all_by_one
      how, what = @selector.shift
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_all_by(how, what)
      else
        raise NotImplementedError, "find all by attribute/other"
      end
    end

    def find_first_by_multiple
      selector = normalized_selector

      idx   = selector.delete(:index)
      xpath = selector[:xpath] || build_xpath(selector)

      if xpath
        # strings only, so we can use the built xpath directly
        if idx
          @wd.find_elements(:xpath, xpath)[idx]
        else
          @wd.find_element(:xpath, xpath)
        end
      else
        # we have at least one regexp
        if idx
          wd_find_by_regexp_selector(selector, :select)[idx]
        else
          wd_find_by_regexp_selector(selector, :find)
        end
      end
    end

    def find_all_by_multiple
      selector = normalized_selector

      if selector.has_key? :index
        raise Error, "can't locate all elements by :index"
      end

      xpath = selector[:xpath] || build_xpath(selector)
      if xpath
        @wd.find_elements(:xpath, xpath)
      else
        wd_find_by_regexp_selector(selector, :select)
      end
    end

    def wd_find_first_by(how, what)
      if what.kind_of? String
        @wd.find_element(how, what)
      else
        all_elements.find { |e| fetch_value(how, e) =~ what }
      end
    end

    def wd_find_all_by(how, what)
      if what.kind_of? String
        @wd.find_elements(how, what)
      else
        all_elements.select { |e| fetch_value(how, e) =~ what }
      end
    end

    def wd_find_by_regexp_selector(selector, method = :find)
      rx_selector = delete_regexps_from(selector)
      xpath = build_xpath(selector) || raise("internal error: unable to build xpath from #{@selector.inspect}")

      elements = @wd.find_elements(:xpath, xpath)
      elements.send(method) { |e| matches_selector?(rx_selector, e) }
    end

    def check_type(how, what)
      case how
      when :index
        raise TypeError, "expected Fixnum, got #{what.class}" unless what.kind_of?(Fixnum)
      else
        unless [String, Regexp].any? { |t| what.kind_of? t }
          raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
        end
      end
    end

    def fetch_value(how, element)
      case how
      when :text
        element.text
      when :tag_name
        element.tag_name
      else
        element.attribute(how) rescue "" # TODO: rescue specific exception
      end
    end

    def matches_selector?(selector, element)
      p :start => selector
      selector.all? do |how, what|
        p :comparing => [how, what], :to => fetch_value(how, element)
        what === fetch_value(how, element)
      end
    end

    def normalized_selector
      selector = {}

      @selector.each do |how, what|
        check_type(how, what)

        how, what = normalize_selector(how, what)
        selector[how] = what
      end

      selector
    end

    def normalize_selector(how, what)
      case how
      when :url
        [:href, what]
      when :caption
        [:text, what]
      else
        [how, what]
      end
    end

    def delete_regexps_from(selector)
      rx_selector = {}

      selector.dup.each do |how, what|
        next unless what.kind_of?(Regexp)
        rx_selector[how] = what
        selector.delete how
      end

      rx_selector
    end

    def by_id
      selector = @selector.dup
      id       = selector.delete(:id)
      return unless id && id.kind_of?(String)

      tag_name = selector.delete(:tag_name)
      return unless selector.empty? # multiple attributes

      element  = @wd.find_element(:id, id)
      return if tag_name && !tag_name_matches?(element, tag_name)

      element
    rescue WebDriver::Error::WebDriverError => wde
      nil
    end
    
    def tag_name_matches?(element, tag_name)
      tag_name === element.tag_name
    end
    
    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      xpath = "//"
      xpath << (selectors.delete(:tag_name) || '*').to_s

      idx = selectors.delete(:index)

      # the remaining entries should be attributes
      unless selectors.empty?
        xpath << "[" << attribute_expression(selectors) << "]"
      end

      if idx
        xpath << "[#{idx + 1}]"
      end

      p :xpath => xpath, :selectors => selectors if $DEBUG

      xpath
    end
    
    def attribute_expression(selectors)
      selectors.map do |key, val| 
        if val.kind_of?(Array)
          "( " + val.map { |v| equal_pair(key, v) }.join(" or ") + " )"
        else
          equal_pair(key, val) 
        end
      end.join(" and ")
    end
    
    def equal_pair(key, value)
      "#{lhs_for(key)}=#{value.to_s.inspect}"
    end

    def lhs_for(key)
      case key
      when :text, 'text'
        'text()'
      else
        "@#{key}"
      end
    end

  end # ElementLocator
  
  class ButtonLocator < ElementLocator
    
    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }
      
      selectors.delete(:tag_name) || raise("internal error: no tag_name?!")
      
      @building = :button
      button_attr_exp = attribute_expression(selectors)
      
      @building = :input
      selectors[:type] = %w[button reset submit]
      input_attr_exp = attribute_expression(selectors)

      xpath = "//button"
      xpath << "[#{button_attr_exp}]" unless button_attr_exp.empty?
      xpath << " | //input"
      xpath << "[#{input_attr_exp}]"
      
      xpath
    end
    
    def lhs_for(key)
      if @building == :input && key == :text
        "@value"
      elsif @building == :button && key == :value
        "text()"
      else
        super
      end
    end
    
    def matches_selector?(rx_selector, element)
      rx_selector = rx_selector.dup
      
      [:value, :caption].each do |key|
        if rx_selector.has_key?(key)
          correct_key = element.tag_name == 'button' ? :text : :value
          rx_selector[correct_key] = rx_selector.delete(key)
        end
      end
      
      super
    end
    
    def tag_name_matches?(element, _)
      !!(/^(input|button)$/ === element.tag_name)
    end
  end
end # Watir
