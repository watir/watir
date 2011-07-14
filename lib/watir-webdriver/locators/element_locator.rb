# encoding: utf-8
module Watir
  class ElementLocator
    include Watir::Exception
    include Selenium

    WD_FINDERS =  [
      :class,
      :class_name,
      :css,
      :id,
      :link,
      :link_text,
      :name,
      :partial_link_text,
      :tag_name,
      :xpath
    ]

    def initialize(wd, selector, valid_attributes)
      @wd               = wd
      @selector         = selector.dup
      @valid_attributes = valid_attributes
    end

    def locate
      e = by_id and return e # short-circuit if :id is given


      if @selector.size == 1
        element = find_first_by_one
      else
        element = find_first_by_multiple
      end

      # this actually only applies when finding by xpath - browser.text_field(:xpath, "//input[@type='radio']")
      # we don't need to validate the element if we built the xpath ourselves.
      validate_element(element) if element
    rescue WebDriver::Error::NoSuchElementError => wde
      nil
    end

    def locate_all
      if @selector.size == 1
        find_all_by_one
      else
        find_all_by_multiple
      end
    end

    private

    def find_first_by_one
      how, what = @selector.to_a.first
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_first_by(how, what)
      else
        find_first_by_multiple
      end
    end

    def find_all_by_one
      how, what = @selector.to_a.first
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_all_by(how, what)
      else
        find_all_by_multiple
      end
    end

    def find_first_by_multiple
      selector = normalized_selector

      idx   = selector.delete(:index)
      xpath = given_xpath(selector) || build_xpath(selector)

      if xpath
        # could build xpath for selector
        if idx
          @wd.find_elements(:xpath, xpath)[idx]
        else
          @wd.find_element(:xpath, xpath)
        end
      else
        # can't use xpath, probably a regexp in there
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
        raise ArgumentError, "can't locate all elements by :index"
      end

      xpath = given_xpath(selector) || build_xpath(selector)
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
        all_elements.find { |element| fetch_value(element, how) =~ what }
      end
    end

    def wd_find_all_by(how, what)
      if what.kind_of? String
        @wd.find_elements(how, what)
      else
        all_elements.select { |element| fetch_value(element, how) =~ what }
      end
    end

    def wd_find_by_regexp_selector(selector, method = :find)
      rx_selector = delete_regexps_from(selector)

      if rx_selector.has_key?(:label) && should_use_label_element?
        selector[:id] = id_from_label(rx_selector.delete(:label)) || return
      end

      xpath = build_xpath(selector) || raise("internal error: unable to build xpath from #{selector.inspect}")

      elements = @wd.find_elements(:xpath, xpath)
      elements.__send__(method) { |el| matches_selector?(el, rx_selector) }
    end

    VALID_WHATS = [String, Regexp]

    def check_type(how, what)
      case how
      when :index
        unless what.kind_of?(Fixnum)
          raise TypeError, "expected Fixnum, got #{what.inspect}:#{what.class}"
        end
      else
        unless VALID_WHATS.any? { |t| what.kind_of? t }
          raise TypeError, "expected one of #{VALID_WHATS.inspect}, got #{what.inspect}:#{what.class}"
        end
      end
    end

    def id_from_label(label_exp)
      # TODO: this won't work correctly if @wd is a sub-element
      label = @wd.find_elements(:tag_name, 'label').find do |el|
        matches_selector?(el, :text => label_exp)
      end

      label.attribute(:for) if label
    end

    def fetch_value(element, how)
      case how
      when :text
        element.text
      when :tag_name
        element.tag_name.downcase
      when :href
        (href = element.attribute(:href)) && href.strip
      else
        element.attribute(how)
      end
    end

    def matches_selector?(element, selector)
      selector.all? do |how, what|
        what === fetch_value(element, how)
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
      when :tag_name, :text, :xpath, :index, :class, :for, :label
        # include :class since the valid attribute is 'class_name'
        # include :for since the valid attribute is 'html_for'
        [how, what]
      when :class_name
        [:class, what]
      when :caption
        [:text, what]
      else
        assert_valid_as_attribute how
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

    def assert_valid_as_attribute(attribute)
      unless valid_attribute? attribute or attribute.to_s =~ /^data_.+$/
        raise MissingWayOfFindingObjectException, "invalid attribute: #{attribute.inspect}"
      end
    end

    def by_id
      return unless id = @selector[:id] and id.kind_of? String

      selector = @selector.dup
      selector.delete(:id)

      tag_name = selector.delete(:tag_name)
      return unless selector.empty? # multiple attributes

      element = @wd.find_element(:id, id)
      return if tag_name && !tag_name_matches?(element.tag_name.downcase, tag_name)

      element
    rescue WebDriver::Error::NoSuchElementError => wde
      nil
    end

    def all_elements
      @wd.find_elements(:xpath => ".//*")
    end

    def tag_name_matches?(element_tag_name, tag_name)
      tag_name === element_tag_name
    end

    def valid_attribute?(attribute)
      @valid_attributes && @valid_attributes.include?(attribute)
    end

    def should_use_label_element?
      @selector[:tag_name] != "option"
    end

    def build_xpath(selectors)
      return if selectors.values.any? { |e| e.kind_of? Regexp }

      xpath = ".//"
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
          "(" + val.map { |v| equal_pair(key, v) }.join(" or ") + ")"
        else
          equal_pair(key, val)
        end
      end.join(" and ")
    end

    def equal_pair(key, value)
      # we assume :label means a corresponding label element, not the attribute
      if key == :label && should_use_label_element?
        "@id=//label[normalize-space()=#{XpathSupport.escape value}]/@for"
      else
        "#{lhs_for(key)}=#{XpathSupport.escape value}"
      end
    end

    def lhs_for(key)
      case key
      when :text, 'text'
        'normalize-space()'
      when :href
        # TODO: change this behaviour?
        'normalize-space(@href)'
      else
        "@#{key.to_s.gsub("_", "-")}"
      end
    end

    def validate_element(element)
      tn = @selector[:tag_name]
      element_tag_name = element.tag_name.downcase

      return if tn && !tag_name_matches?(element_tag_name, tn)

      if element_tag_name == 'input'
        return if @selector[:type] && @selector[:type] != element.attribute(:type)
      end

      element
    end

    def given_xpath(selector)
      return unless xpath = selector.delete(:xpath)

      unless selector.empty? || can_be_combined_with_xpath?(selector)
        raise ArgumentError, ":xpath cannot be combined with other selectors (#{selector.inspect})"
      end

      xpath
    end

    def can_be_combined_with_xpath?(selector)
      # ouch - is this worth it?
      keys = selector.keys
      return true if keys == [:tag_name]

      if selector[:tag_name] == "input"
        return keys == [:tag_name, :type] || keys == [:type, :tag_name]
      end

      false
    end

  end # ElementLocator
end # Watir
