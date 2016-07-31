module Watir
  module Locators
    class Element
      class Locator
        attr_reader :selector_builder
        attr_reader :element_validator

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

        # Regular expressions that can be reliably converted to xpath `contains`
        # expressions in order to optimize the .
        CONVERTABLE_REGEXP = %r{
          \A
            ([^\[\]\\^$.|?*+()]*) # leading literal characters
            [^|]*?                # do not try to convert expressions with alternates
            ([^\[\]\\^$.|?*+()]*) # trailing literal characters
          \z
        }x

        def initialize(parent, selector, selector_builder, element_validator)
          @parent = parent # either element or browser
          @selector = selector.dup
          @selector_builder = selector_builder
          @element_validator = element_validator
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
          element_validator.validate(element, @selector) if element
        rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::StaleElementReferenceError
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

        def by_id
          return unless id = @selector[:id] and id.is_a? String

          selector = @selector.dup
          selector.delete(:id)

          tag_name = selector.delete(:tag_name)
          return unless selector.empty? # multiple attributes

          element = @parent.wd.find_element(:id, id)
          return if tag_name && !element_validator.validate(element, selector)

          element
        end

        def find_first_by_one
          how, what = @selector.to_a.first
          selector_builder.check_type(how, what)

          if WD_FINDERS.include?(how)
            wd_find_first_by(how, what)
          else
            find_first_by_multiple
          end
        end

        def find_first_by_multiple
          selector = selector_builder.normalized_selector

          idx = selector.delete(:index)
          how, what = selector_builder.build(selector)

          if how
            # could build xpath/css for selector
            if idx
              @parent.wd.find_elements(how, what)[idx]
            else
              @parent.wd.find_element(how, what)
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

        def find_all_by_one
          how, what = @selector.to_a.first
          selector_builder.check_type how, what

          if WD_FINDERS.include?(how)
            wd_find_all_by(how, what)
          else
            find_all_by_multiple
          end
        end

        def find_all_by_multiple
          selector = selector_builder.normalized_selector

          if selector.key? :index
            raise ArgumentError, "can't locate all elements by :index"
          end

          how, what = selector_builder.build(selector)
          if how
            @parent.wd.find_elements(how, what)
          else
            wd_find_by_regexp_selector(selector, :select)
          end
        end

        def wd_find_all_by(how, what)
          if what.is_a? String
            @parent.wd.find_elements(how, what)
          else
            all_elements.select { |element| fetch_value(element, how) =~ what }
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
            element.attribute(how.to_s.tr("_", "-").to_sym)
          end
        end

        def all_elements
          @parent.wd.find_elements(xpath: ".//*")
        end

        def wd_find_first_by(how, what)
          if what.is_a? String
            @parent.wd.find_element(how, what)
          else
            all_elements.find { |element| fetch_value(element, how) =~ what }
          end
        end

        def wd_find_by_regexp_selector(selector, method = :find)
          parent = @parent.wd
          rx_selector = delete_regexps_from(selector)

          if rx_selector.key?(:label) && selector_builder.should_use_label_element?
            label = label_from_text(rx_selector.delete(:label)) || return
            if (id = label.attribute(:for))
              selector[:id] = id
            else
              parent = label
            end
          end

          how, what = selector_builder.build(selector)

          unless how
            raise Error, "internal error: unable to build WebDriver selector from #{selector.inspect}"
          end

          if how == :xpath && can_convert_regexp_to_contains?
            rx_selector.each do |key, value|
              next if key == :tag_name || key == :text

              predicates = regexp_selector_to_predicates(key, value)
              what = "(#{what})[#{predicates.join(' and ')}]" unless predicates.empty?
            end
          end

          elements = parent.find_elements(how, what)
          elements.__send__(method) { |el| matches_selector?(el, rx_selector) }
        end

        def delete_regexps_from(selector)
          rx_selector = {}

          selector.dup.each do |how, what|
            next unless what.is_a?(Regexp)
            rx_selector[how] = what
            selector.delete how
          end

          rx_selector
        end

        def label_from_text(label_exp)
          # TODO: this won't work correctly if @wd is a sub-element
          @parent.wd.find_elements(:tag_name, 'label').find do |el|
            matches_selector?(el, text: label_exp)
          end
        end

        def matches_selector?(element, selector)
          selector.all? do |how, what|
            what === fetch_value(element, how)
          end
        end

        def can_convert_regexp_to_contains?
          true
        end

        def regexp_selector_to_predicates(key, re)
          return [] if re.casefold?

          match = re.source.match(CONVERTABLE_REGEXP)
          return [] unless match

          lhs = selector_builder.xpath_builder.lhs_for(nil, key)
          match.captures.reject(&:empty?).map do |literals|
            "contains(#{lhs}, #{XpathSupport.escape(literals)})"
          end
        end
      end
    end
  end
end
