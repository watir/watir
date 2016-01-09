module Watir
  class Element
    class SelectorBuilder
      VALID_WHATS = [String, Regexp]
      WILDCARD_ATTRIBUTE = /^(aria|data)_(.+)$/

      def initialize(wd, selector, valid_attributes)
        @wd = wd # TODO: get rid of wd, it's only used in child cells
        @selector = selector
        @valid_attributes = valid_attributes
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

      def check_type(how, what)
        case how
        when :index
          unless what.is_a?(Fixnum)
            raise TypeError, "expected Fixnum, got #{what.inspect}:#{what.class}"
          end
        else
          unless VALID_WHATS.any? { |t| what.is_a? t }
            raise TypeError, "expected one of #{VALID_WHATS.inspect}, got #{what.inspect}:#{what.class}"
          end
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
          "@#{key.to_s.tr("_", "-")}"
        end
      end

      def should_use_label_element?
        !valid_attribute?(:label)
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

      def build_wd_selector(selectors)
        unless selectors.values.any? { |e| e.is_a? Regexp }
          build_css(selectors) || build_xpath(selectors)
        end
      end

      def attribute_expression(selectors)
        f = selectors.map do |key, val|
          if val.is_a?(Array)
            "(" + val.map { |v| equal_pair(key, v) }.join(" or ") + ")"
          else
            equal_pair(key, val)
          end
        end
        f.join(" and ")
      end

      private

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

      def assert_valid_as_attribute(attribute)
        return if valid_attribute?(attribute) || attribute.to_s =~ WILDCARD_ATTRIBUTE
        raise Exception::MissingWayOfFindingObjectException, "invalid attribute: #{attribute.inspect}"
      end

      def valid_attribute?(attribute)
        @valid_attributes && @valid_attributes.include?(attribute)
      end

      def can_be_combined_with_xpath_or_css?(selector)
        keys = selector.keys
        return true if keys == [:tag_name]

        if selector[:tag_name] == "input"
          return keys.sort == [:tag_name, :type]
        end

        false
      end

      def build_xpath(selectors)
        xpath = ".//"
        xpath << (selectors.delete(:tag_name) || '*').to_s

        selectors.delete :index

        # the remaining entries should be attributes
        unless selectors.empty?
          xpath << "[" << attribute_expression(selectors) << "]"
        end

        p xpath: xpath, selectors: selectors if $DEBUG

        [:xpath, xpath]
      end

      def build_css(selectors)
        return unless use_css?(selectors)

        if selectors.empty?
          css = '*'
        else
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
            key = key.to_s.tr("_", "-")
            css << %([#{key}="#{css_escape value}"]) # TODO: proper escaping
          end
        end

        [:css, css]
      end

      def use_css?(selectors)
        return false unless Watir.prefer_css?

        if selectors.key?(:text) || selectors.key?(:label) || selectors.key?(:index)
          return false
        end

        if selectors[:tag_name] == 'input' && selectors.key?(:type)
          return false
        end

        if selectors.key?(:class) && selectors[:class] !~ /^[\w-]+$/ui
          return false
        end

        true
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
    end
  end
end
