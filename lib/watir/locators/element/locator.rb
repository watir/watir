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
        # expressions in order to optimize the locator.
        CONVERTABLE_REGEXP = %r{
          \A
            ([^\[\]\\^$.|?*+()]*) # leading literal characters
            [^|]*?                # do not try to convert expressions with alternates
            ([^\[\]\\^$.|?*+()]*) # trailing literal characters
          \z
        }x

        def initialize(query_scope, selector, selector_builder, element_validator)
          @query_scope = query_scope # either element or browser
          @selector = selector.dup
          @selector_builder = selector_builder
          @element_validator = element_validator
        end

        def locate
          using_selenium(:first) || using_watir(:first)
        rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::StaleElementReferenceError
          nil
        end

        def locate_all
          return [@selector[:element]] if @selector.key?(:element)
          using_selenium(:all) || using_watir(:all)
        end

        private

        def using_selenium(filter = :first)
          selector = @selector.dup
          tag_name = selector[:tag_name].is_a?(::Symbol) ? selector[:tag_name].to_s : selector[:tag_name]
          selector.delete(:tag_name) if selector.size > 1

          WD_FINDERS.each do |sel|
            next unless (value = selector.delete(sel))
            return unless selector.empty? && wd_supported?(sel, value)
            if filter == :all
              found = locate_elements(sel, value)
              return found if sel == :tag_name
              return filter_elements_by_locator(found, tag_name: tag_name, filter: filter).compact
            else
              found = locate_element(sel, value)
              return sel != :tag_name && tag_name && !validate([found], tag_name) ? nil : found
            end
          end
          nil
        end

        def using_watir(filter = :first)
          selector = selector_builder.normalized_selector
          visible = selector.delete(:visible)
          visible_text = selector.delete(:visible_text)
          tag_name = selector[:tag_name].is_a?(::Symbol) ? selector[:tag_name].to_s : selector[:tag_name]
          validation_required = (selector.key?(:css) || selector.key?(:xpath)) && tag_name

          if selector.key?(:index) && filter == :all
            raise ArgumentError, "can't locate all elements by :index"
          end
          idx = selector.delete(:index) unless selector[:adjacent]

          how, what = selector_builder.build(selector)

          needs_filtering = idx && idx != 0 || !visible.nil? || !visible_text.nil? || validation_required || filter == :all

          if needs_filtering
            matching = matching_elements(how, what, selector)
            return filter_elements_by_locator(matching, visible, visible_text, idx, tag_name: tag_name, filter: filter)
          elsif how
            locate_element(how, what)
          else
            wd_find_by_regexp_selector(selector, :first)
          end
        end

        def validate(elements, tag_name)
          elements.compact.all? { |element| element_validator.validate(element, {tag_name: tag_name}) }
        end

        def matching_elements(how, what, selector = nil)
          found = how ? locate_elements(how, what) : wd_find_by_regexp_selector(selector, :all)
          found || []
        end

        def fetch_value(element, how)
          case how
          when :text
            vis = element.text
            all = Watir::Element.new(@query_scope, element: element).send(:execute_js, :getTextContent, element).strip
            unless all == vis.strip
              Watir.logger.deprecate(':text locator with RegExp values to find elements based on only visible text', ":visible_text")
            end
            vis
          when :visible_text
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
          locate_elements(:xpath, ".//*")
        end

        def wd_find_by_regexp_selector(selector, filter)
          query_scope = ensure_scope_context
          rx_selector = delete_regexps_from(selector)

          if rx_selector.key?(:label) && selector_builder.should_use_label_element?
            label = label_from_text(rx_selector.delete(:label)) || return
            if (id = label.attribute('for'))
              selector[:id] = id
            else
              query_scope = label
            end
          end

          how, what = selector_builder.build(selector)

          unless how
            raise Error, "internal error: unable to build Selenium selector from #{selector.inspect}"
          end

          if how == :xpath && can_convert_regexp_to_contains?
            rx_selector.each do |key, value|
              next if key == :tag_name || key == :text

              predicates = regexp_selector_to_predicates(key, value)
              what = "(#{what})[#{predicates.join(' and ')}]" unless predicates.empty?
            end
          end

          elements = locate_elements(how, what, query_scope)
          filter_elements_by_regex(elements, rx_selector, filter)
        end

        def filter_elements_by_locator(elements, visible = nil, visible_text = nil, idx = nil, tag_name: nil, filter: :first)
          elements.select! { |el| visible == el.displayed? } unless visible.nil?
          elements.select! { |el| visible_text === el.text } unless visible_text.nil?
          elements.select! { |el| element_validator.validate(el, {tag_name: tag_name}) } unless tag_name.nil?
          filter == :first ? elements[idx || 0] : elements
        end

        def filter_elements_by_regex(elements, selector, filter)
          method = filter == :first ? :find : :select
          elements.__send__(method) { |el| matches_selector?(el, selector) }
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
          locate_elements(:tag_name, 'label').find do |el|
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

        def ensure_scope_context
          @query_scope.wd
        end

        def locate_element(how, what, scope = @query_scope.wd)
          scope.find_element(how, what)
        end

        def locate_elements(how, what, scope = @query_scope.wd)
          scope.find_elements(how, what)
        end

        def wd_supported?(how, what)
          return false unless what.kind_of?(String)
          return false if [:class, :class_name].include?(how) && what.include?(' ')
          %i[partial_link_text link_text link].each do |loc|
            next unless how == loc
            Watir.logger.deprecate(":#{loc} locator", ':visible_text')
          end
          true
        end
      end
    end
  end
end
