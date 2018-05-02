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
              filter_selector = tag_name ? {tag_name: tag_name} : {}
              return filter_elements(found, filter_selector, filter: filter).compact
            else
              found = locate_element(sel, value)
              return sel != :tag_name && tag_name && !validate([found], tag_name) ? nil : found
            end
          end
          nil
        end

        def using_watir(filter = :first)
          query_scope = ensure_scope_context
          selector = selector_builder.normalized_selector

          if selector[:label]
            query_scope = convert_label_to_scope_or_selector(query_scope, selector)
            return unless query_scope # stop, label not found
          end

          if selector.key?(:index) && filter == :all
            raise ArgumentError, "can't locate all elements by :index"
          end

          filter_selector = delete_filters_from(selector)

          how, what = selector_builder.build(selector)
          unless how
            raise Error, "internal error: unable to build Selenium selector from #{selector.inspect}"
          end
          what = add_regexp_predicates(what, filter_selector) if how == :xpath

          needs_filtering = filter == :all || !filter_selector.empty?
          if needs_filtering
            elements = locate_elements(how, what, query_scope) || []
            filter_elements(elements, filter_selector, filter: filter)
          else
            locate_element(how, what, query_scope)
          end
        end

        def validate(elements, tag_name)
          elements.compact.all? { |element| element_validator.validate(element, {tag_name: tag_name}) }
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
          when :visible
            element.displayed?
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

        def filter_elements(elements, selector, filter: :first)
          if filter == :first
            idx = selector.delete(:index) || 0
            if idx < 0
              elements.reverse!
              idx = idx.abs - 1
            end

            # Lazy evaluation to avoid fetching values for elements that will be discarded
            matches = elements.lazy.select { |el| matches_selector?(el, selector) }
            matches.take(idx + 1).to_a[idx]
          else
            elements.select { |el| matches_selector?(el, selector) }
          end
        end

        def delete_filters_from(selector)
          filter_selector = {}

          # Remove selectors that can never be used in XPath builder
          [:visible, :visible_text].each do |how|
            next unless selector.key?(how)
            filter_selector[how] = selector.delete(how)
          end

          if tag_validation_required?(selector)
            tag_name = selector[:tag_name].is_a?(::Symbol) ? selector[:tag_name].to_s : selector[:tag_name]
            filter_selector[:tag_name] = tag_name
          end

          # Regexp locators currently need to be validated even if they are included in the XPath builder
          # TODO: Identify Regexp that can have an exact equivalent using XPath contains (ie would not require
          #  filtering) vs approximations (ie would still requiring filtering)
          selector.dup.each do |how, what|
            next unless what.is_a?(Regexp)
            filter_selector[how] = selector.delete(how)
          end

          if selector[:index] && !selector[:adjacent]
            idx = selector.delete(:index)

            # Do not add {index: 0} filter if the only filter. This will allow using #find_element instead of #find_elements.
            implicit_idx_filter = filter_selector.empty? && idx == 0
            filter_selector[:index] = idx unless implicit_idx_filter
          end

          filter_selector
        end

        def convert_label_to_scope_or_selector(query_scope, selector)
          return query_scope unless selector[:label].kind_of?(Regexp) && selector_builder.should_use_label_element?

          label = label_from_text(selector.delete(:label))
          return unless label # label not found, stop looking for element

          if (id = label.attribute('for'))
            selector[:id] = id
            query_scope
          else
            label
          end
        end

        def label_from_text(label_exp)
          # TODO: this won't work correctly if @wd is a sub-element
          locate_elements(:tag_name, 'label').find do |el|
            matches_selector?(el, text: label_exp)
          end
        end

        def matches_selector?(element, selector)
          selector.all? do |how, what|
            if how == :tag_name && what.is_a?(String)
              element_validator.validate(element, {tag_name: what})
            else
              what === fetch_value(element, how)
            end
          end
        end

        def can_convert_regexp_to_contains?
          true
        end

        def add_regexp_predicates(what, filter_selector)
          return what unless can_convert_regexp_to_contains?

          filter_selector.each do |key, value|
            next if [:tag_name, :text, :visible_text, :visible, :index].include?(key)

            predicates = regexp_selector_to_predicates(key, value)
            unless predicates.empty?
              what = "(#{what})[#{predicates.join(' and ')}]"
            end
          end
          what
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

        def tag_validation_required?(selector)
          (selector.key?(:css) || selector.key?(:xpath)) && selector.key?(:tag_name)
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
