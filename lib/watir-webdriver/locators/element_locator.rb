# encoding: utf-8
module Watir
  class ElementLocator
    include Watir::Exception

    WD_FINDERS = [
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

    WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/

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

      # This actually only applies when finding by xpath/css - browser.text_field(:xpath, "//input[@type='radio']")
      # We don't need to validate the element if we built the xpath ourselves.
      # It is also used to alter behavior of methods locating more than one type of element
      # (e.g. text_field locates both input and textarea)
      validate_element(element) if element
    rescue Selenium::WebDriver::Error::NoSuchElementError
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

      idx = selector.delete(:index)
      how, what = given_xpath_or_css(selector) || build_wd_selector(selector)

      if how
        # could build xpath/css for selector
        if idx
          @wd.find_elements(how, what)[idx]
        else
          @wd.find_element(how, what)
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

      how, what = given_xpath_or_css(selector) || build_wd_selector(selector)
      if how
        @wd.find_elements(how, what)
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
      parent = @wd
      rx_selector = delete_regexps_from(selector)

      if rx_selector.has_key?(:label) && should_use_label_element?
        label = label_from_text(rx_selector.delete(:label)) || return
        if (id = label.attribute(:for))
          selector[:id] = id
        else
          parent = label
        end
      end

      how, what = build_wd_selector(selector)

      unless how
        raise Error, "internal error: unable to build WebDriver selector from #{selector.inspect}"
      end

      elements = parent.find_elements(how, what)
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

    def label_from_text(label_exp)
      # TODO: this won't work correctly if @wd is a sub-element
      @wd.find_elements(:tag_name, 'label').find do |el|
        matches_selector?(el, :text => label_exp)
      end
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
        element.attribute(how.to_s.gsub("_", "-").to_sym)
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
      when :tag_name, :text, :xpath, :index, :class, :label, :css
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
      unless valid_attribute? attribute or attribute.to_s =~ WILDCARD_ATTRIBUTE
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
    rescue Selenium::WebDriver::Error::NoSuchElementError
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
      !valid_attribute?(:label)
    end

    def build_wd_selector(selectors)
      unless selectors.values.any? { |e| e.kind_of? Regexp }
        build_css(selectors) || build_xpath(selectors)
      end
    end

    def build_xpath(selectors)
      xpath = ".//"
      xpath << (selectors.delete(:tag_name) || '*').to_s

      idx = selectors.delete :index

      # the remaining entries should be attributes
      unless selectors.empty?
        xpath << "[" << attribute_expression(selectors) << "]"
      end

      p :xpath => xpath, :selectors => selectors if $DEBUG

      [:xpath, xpath]
    end

    def build_css(selectors)
      return unless use_css?(selectors)

      css = ''
      css << (selectors.delete(:tag_name) || '')

      klass = selectors.delete(:class)
      if klass
        if klass.include? ' '
          css << %([class="#{css_escape klass}"])
        else
          css << ".#{klass}"
        end
      end

      href = selectors.delete(:href)
      if href
        css << %([href~="#{css_escape href}"])
      end

      selectors.each do |key, value|
        key = key.to_s.gsub("_", "-")
        css << %([#{key}="#{css_escape value}"]) # TODO: proper escaping
      end

      [:css, css]
    end

    def use_css?(selectors)
      return false unless Watir.prefer_css?

      if selectors.has_key?(:text) || selectors.has_key?(:label) || selectors.has_key?(:index)
        return false
      end

      if selectors[:tag_name] == 'input' && selectors.has_key?(:type)
        return false
      end

      if selectors.has_key?(:class) && selectors[:class] !~ /^[\w-]+$/ui
        return false
      end

      true
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

    def css_escape(str)
      str.gsub('"', '\\"')
    end

    def equal_pair(key, value)
      if key == :class
        klass = XpathSupport.escape " #{value} "
        "contains(concat(' ', @class, ' '), #{klass})"
      elsif key == :label && should_use_label_element?
        # we assume :label means a corresponding label element, not the attribute
        text = "normalize-space()=#{XpathSupport.escape value}"
        "(@id=//label[#{text}]/@for or parent::label[#{text}])"
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
      when :type
        # type attributes can be upper case - downcase them
        # https://github.com/watir/watir-webdriver/issues/72
        XpathSupport.downcase('@type')
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

    def given_xpath_or_css(selector)
      xpath = selector.delete(:xpath)
      css   = selector.delete(:css)
      return unless xpath || css

      if xpath && css
        raise ArgumentError, ":xpath and :css cannot be combined (#{selector.inspect})"
      end

      how, what = if xpath
                    [:xpath, xpath]
                  elsif css
                    [:css, css]
                  end

      if selector.any? && !can_be_combined_with_xpath_or_css?(selector)
        raise ArgumentError, "#{how} cannot be combined with other selectors (#{selector.inspect})"
      end

      [how, what]
    end

    def can_be_combined_with_xpath_or_css?(selector)
      keys = selector.keys
      return true if keys == [:tag_name]

      if selector[:tag_name] == "input"
        return keys == [:tag_name, :type] || keys == [:type, :tag_name]
      end

      false
    end

  end # ElementLocator
end # Watir
