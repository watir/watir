module Watir
  module Locators
    class Element
      class Locator
        attr_reader :selector_builder
        attr_reader :element_validator

        W3C_FINDERS = %i[
          css
          link
          link_text
          partial_link_text
          tag_name
          xpath
        ].freeze

        # Regular expressions that can be reliably converted to xpath `contains`
        # expressions in order to optimize the locator.
        CONVERTABLE_REGEXP = /
          \A
            ([^\[\]\\^$.|?*+()]*) # leading literal characters
            [^|]*?                # do not try to convert expressions with alternates
            ([^\[\]\\^$.|?*+()]*) # trailing literal characters
          \z
        /x

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
          tag = @selector[:tag_name].is_a?(::Symbol) ? @selector.delete(:tag_name).to_s : @selector.delete(:tag_name)
          return if @selector.size > 1

          how = @selector.keys.first || :tag_name
          what = @selector.values.first || tag

          return unless wd_supported?(how, what, tag)

          filter == :all ? locate_elements(how, what) : locate_element(how, what)
        end

        def using_watir(filter = :first)
          create_normalized_selector(filter)
          return unless @normalized_selector

          create_filter_selector

          how, what = selector_builder.build(@normalized_selector.dup)
          unless how
            raise Error, "internal error: unable to build Selenium selector from #{@normalized_selector.inspect}"
          end

          what = add_regexp_predicates(what) if how == :xpath

          if filter == :all || !@filter_selector.empty?
            locate_filtered_elements(how, what, filter)
          else
            locate_element(how, what, @driver_scope)
          end
        end

        def validate(elements, tag_name)
          elements.compact.all? { |element| element_validator.validate(element, tag_name: tag_name) }
        end

        def fetch_value(element, how)
          case how
          when :text
            element.text
          when :visible
            element.displayed?
          when :visible_text
            element.text
          when :tag_name
            element.tag_name.downcase
          when :href
            element.attribute('href')&.strip
          when String, ::Symbol
            how = how.to_s.tr('_', '-') if how.is_a?(::Symbol)
            element.attribute(how)
          else
            raise Error::Exception, "Unable to fetch value for #{how}"
          end
        end

        def filter_elements(elements, filter: :first)
          selector = @filter_selector.dup
          if filter == :first
            idx = element_index(elements, selector)
            counter = 0

            # Lazy evaluation to avoid fetching values for elements that will be discarded
            matches = elements.lazy.select do |el|
              counter += 1
              matches_selector?(el, selector)
            end
            msg = "Filtered through #{counter} elements to locate #{@selector.inspect}"
            matches.take(idx + 1).to_a[idx].tap { Watir.logger.debug msg }
          else
            Watir.logger.debug "Iterated through #{elements.size} elements to locate all #{@selector.inspect}"
            elements.select { |el| matches_selector?(el, selector) }
          end
        end

        def element_index(elements, selector)
          idx = selector.delete(:index) || 0
          return idx unless idx.negative?

          elements.reverse!
          idx.abs - 1
        end

        def create_normalized_selector(filter)
          return @normalized_selector if @normalized_selector

          @driver_scope = @query_scope.wd

          @normalized_selector = selector_builder.normalized_selector

          if @normalized_selector.key?(:label)
            label_key = :label
          elsif @normalized_selector.key?(:visible_label)
            label_key = :visible_label
          end

          if label_key
            process_label(label_key)
            return if @normalized_selector.nil?
          end

          if @normalized_selector.key?(:index) && filter == :all
            raise ArgumentError, "can't locate all elements by :index"
          end

          @normalized_selector
        end

        def create_filter_selector
          return @filter_selector if @filter_selector

          @filter_selector = {}

          # Remove selectors that can never be used in XPath builder
          %i[visible visible_text].each do |how|
            next unless @normalized_selector.key?(how)

            @filter_selector[how] = @normalized_selector.delete(how)
          end

          set_tag_validation if tag_validation_required?(@normalized_selector)

          # Regexp locators currently need to be validated even if they are included in the XPath builder
          # TODO: Identify Regexp that can have an exact equivalent using XPath contains (ie would not require
          #  filtering) vs approximations (ie would still requiring filtering)
          @normalized_selector.each do |how, what|
            next unless what.is_a?(Regexp)

            @filter_selector[how] = @normalized_selector.delete(how)
          end

          if @normalized_selector[:index] && !@normalized_selector[:adjacent]
            idx = @normalized_selector.delete(:index)

            # Do not add {index: 0} filter if the only filter.
            # This will allow using #find_element instead of #find_elements.
            implicit_idx_filter = @filter_selector.empty? && idx.zero?
            @filter_selector[:index] = idx unless implicit_idx_filter
          end

          @filter_selector
        end

        def set_tag_validation
          @filter_selector[:tag_name] = if @normalized_selector[:tag_name].is_a?(::Symbol)
                                          @normalized_selector[:tag_name].to_s
                                        else
                                          @normalized_selector[:tag_name]
                                        end
        end

        def process_label(label_key)
          regexp = @normalized_selector[label_key].is_a?(Regexp)
          return unless (regexp || label_key == :visible_label) && selector_builder.should_use_label_element?

          label = label_from_text(label_key)
          unless label # label not found, stop looking for element
            @normalized_selector = nil
            return
          end

          if (id = label.attribute('for'))
            @normalized_selector[:id] = id
          else
            @driver_scope = label
          end
        end

        def label_from_text(label_key)
          # TODO: this won't work correctly if @wd is a sub-element, write spec
          # TODO: Figure out how to do this with find_element
          label_text = @normalized_selector.delete(label_key)
          locator_key = label_key.to_s.gsub('label', 'text').to_sym
          locate_elements(:tag_name, 'label', @driver_scope).find do |el|
            matches_selector?(el, locator_key => label_text)
          end
        end

        def matches_selector?(element, selector)
          matches = selector.all? do |how, what|
            if how == :tag_name && what.is_a?(String)
              element_validator.validate(element, tag_name: what)
            else
              val = fetch_value(element, how)
              what == val || val =~ /#{what}/
            end
          end

          text_regexp_deprecation(element, selector, matches) if selector[:text]

          matches
        end

        def text_regexp_deprecation(element, selector, matches)
          new_element = Watir::Element.new(@query_scope, element: element)
          text_content = new_element.execute_js(:getTextContent, element).strip
          text_content_matches = text_content =~ /#{selector[:text]}/
          return if matches == !!text_content_matches

          key = @selector.key?(:text) ? 'text' : 'label'
          selector_text = selector[:text].inspect
          dep = "Using :#{key} locator with RegExp #{selector_text} to match an element that includes hidden text"
          Watir.logger.deprecate(dep, ":visible_#{key}", ids: [:text_regexp])
        end

        def can_convert_regexp_to_contains?
          true
        end

        def add_regexp_predicates(what)
          return what unless can_convert_regexp_to_contains?

          @filter_selector.each do |key, value|
            next if %i[tag_name text visible_text visible index].include?(key)

            predicates = regexp_selector_to_predicates(key, value)
            what = "(#{what})[#{predicates.join(' and ')}]" unless predicates.empty?
          end
          what
        end

        def regexp_selector_to_predicates(key, regexp)
          return [] if regexp.casefold?

          match = regexp.source.match(CONVERTABLE_REGEXP)
          return [] unless match

          lhs = selector_builder.xpath_builder.lhs_for(nil, key)
          match.captures.reject(&:empty?).map do |literals|
            "contains(#{lhs}, #{XpathSupport.escape(literals)})"
          end
        end

        def tag_validation_required?(selector)
          (selector.key?(:css) || selector.key?(:xpath)) && selector.key?(:tag_name)
        end

        def locate_element(how, what, scope = @query_scope.wd)
          scope.find_element(how, what)
        end

        def locate_elements(how, what, scope = @query_scope.wd)
          scope.find_elements(how, what)
        end

        def locate_filtered_elements(how, what, filter)
          retries = 0
          begin
            elements = locate_elements(how, what, @driver_scope) || []
            filter_elements(elements, filter: filter)
          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            retries += 1
            sleep 0.5
            retry unless retries > 2
            target = filter == :all ? 'element collection' : 'element'
            raise StandardError, "Unable to locate #{target} from #{@selector} due to changing page"
          end
        end

        def wd_supported?(how, what, tag)
          return false unless W3C_FINDERS.include? how
          return false unless what.is_a?(String)

          if %i[partial_link_text link_text link].include?(how)
            Watir.logger.deprecate(":#{how} locator", ':visible_text', ids: [:visible_text])
            return true if [:a, :link, nil].include?(tag)

            raise StandardError, "Can not use #{how} locator to find a #{what} element"
          elsif how == :tag_name
            return true
          else
            return false unless tag.nil?
          end
          true
        end
      end
    end
  end
end
