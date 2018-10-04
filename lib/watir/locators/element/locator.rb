module Watir
  module Locators
    class Element
      class Locator
        include Exception

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

        def initialize(query_scope, selector, selector_builder, element_validator)
          @query_scope = query_scope # either element or browser
          @selector = selector
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
          tag = selector[:tag_name].is_a?(::Symbol) ? selector.delete(:tag_name).to_s : selector.delete(:tag_name)
          return if selector.size > 1

          how = selector.keys.first || :tag_name
          what = selector.values.first || tag

          return unless wd_supported?(how, what, tag)

          filter == :all ? locate_elements(how, what) : locate_element(how, what)
        end

        def using_watir(filter = :first)
          raise ArgumentError, "can't locate all elements by :index" if @selector.key?(:index) && filter == :all

          begin
            generate_scope
          rescue LocatorException
            return nil
          end

          selector, values_to_match = selector_builder.build(@selector)

          validate_built_selector(selector, values_to_match)

          if filter == :all || values_to_match.any?
            locate_matching_elements(selector, values_to_match, filter)
          else
            locate_element(selector.keys.first, selector.values.first, @driver_scope)
          end
        end

        def validate_built_selector(selector, values_to_match)
          if selector.nil?
            msg = "#{selector_builder.class} was unable to build selector from #{@selector.inspect}"
            raise LocatorException, msg
          elsif values_to_match.nil?
            msg = "#{selector_builder.class}#build is not returning expected responses for the current version of Watir"
            raise LocatorException, msg
          end
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
          else
            how = how.to_s.tr('_', '-') if how.is_a?(::Symbol)
            element.attribute(how)
          end
        end

        def matching_elements(elements, values_to_match, filter: :first)
          if filter == :first
            idx = element_index(elements, values_to_match)
            counter = 0

            # Lazy evaluation to avoid fetching values for elements that will be discarded
            matches = elements.lazy.select do |el|
              counter += 1
              matches_values?(el, values_to_match)
            end
            msg = "iterated through #{counter} elements to locate #{@selector.inspect}"
            matches.take(idx + 1).to_a[idx].tap { Watir.logger.debug msg }
          else
            Watir.logger.debug "Iterated through #{elements.size} elements to locate all #{@selector.inspect}"
            elements.select { |el| matches_values?(el, values_to_match) }
          end
        end

        def element_index(elements, values_to_match)
          idx = values_to_match.delete(:index) || 0
          return idx unless idx.negative?

          elements.reverse!
          idx.abs - 1
        end

        def generate_scope
          return @driver_scope if @driver_scope

          @driver_scope = @query_scope.wd

          if @selector.key?(:label)
            process_label :label
          elsif @selector.key?(:visible_label)
            process_label :visible_label
          end
        end

        def process_label(label_key)
          regexp = @selector[label_key].is_a?(Regexp)
          return unless (regexp || label_key == :visible_label) && selector_builder.should_use_label_element?

          label = label_from_text(label_key)
          msg = "Unable to locate element with label #{label_key}: #{@selector[label_key]}"
          raise LocatorException, msg unless label

          id = label.attribute('for')
          if id
            @selector[:id] = id
          else
            @driver_scope = label
          end
        end

        def label_from_text(label_key)
          # TODO: this won't work correctly if @wd is a sub-element, write spec
          # TODO: Figure out how to do this with find_element
          label_text = @selector.delete(label_key)
          locator_key = label_key.to_s.gsub('label', 'text').gsub('_element', '').to_sym
          locate_elements(:tag_name, 'label', @driver_scope).find do |el|
            matches_values?(el, locator_key => label_text)
          end
        end

        def matches_values?(element, values_to_match)
          matches = values_to_match.all? do |how, what|
            if how == :tag_name && what.is_a?(String)
              element_validator.validate(element, what)
            else
              val = fetch_value(element, how)
              what == val || val =~ /#{what}/
            end
          end

          text_regexp_deprecation(element, values_to_match, matches) if values_to_match[:text]

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

        def locate_element(how, what, scope = @query_scope.wd)
          scope.find_element(how, what)
        end

        def locate_elements(how, what, scope = @query_scope.wd)
          scope.find_elements(how, what)
        end

        def locate_matching_elements(selector, values_to_match, filter)
          retries = 0
          begin
            elements = locate_elements(selector.keys.first, selector.values.first, @driver_scope) || []
            matching_elements(elements, values_to_match, filter: filter)
          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            retries += 1
            sleep 0.5
            retry unless retries > 2
            target = filter == :all ? 'element collection' : 'element'
            raise LocatorException, "Unable to locate #{target} from #{@selector} due to changing page"
          end
        end

        def wd_supported?(how, what, tag)
          return false unless W3C_FINDERS.include? how
          return false unless what.is_a?(String)

          if %i[partial_link_text link_text link].include?(how)
            Watir.logger.deprecate(":#{how} locator", ':visible_text', ids: [:link_text])
            return true if [:a, :link, nil].include?(tag)

            raise LocatorException, "Can not use #{how} locator to find a #{what} element"
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
