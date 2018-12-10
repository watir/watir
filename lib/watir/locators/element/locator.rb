module Watir
  module Locators
    class Element
      class Locator
        include Exception

        attr_reader :selector_builder, :element_matcher

        def initialize(query_scope, selector, selector_builder, element_matcher)
          @query_scope = query_scope
          @selector = selector
          @selector_builder = selector_builder
          @element_matcher = element_matcher
        end

        def locate
          matching_elements(:first)
        rescue Selenium::WebDriver::Error::NoSuchElementError
          nil
        end

        def locate_all
          raise ArgumentError, "can't locate all elements by :index" if @selector.key?(:index)

          [matching_elements(:all)].flatten
        end

        private

        def matching_elements(filter = :first)
          return @selector[:element] if @selector.key?(:element)
          built = selector_builder.built

          return locate_element(*built.to_a.flatten, @query_scope.wd) if built.size == 1 && filter == :first

          wd_locator_key = selector_builder.wd_locator(built.keys)
          wd_locator = built.select { |k, _v| wd_locator_key == k }
          match_values = built.reject { |k, _v| wd_locator_key == k }

          # TODO: Wrap this to continue trying until default timeout
          retries = 0
          begin
            elements = locate_elements(*wd_locator.to_a.flatten, @query_scope.wd)

            element_matcher.match(elements, match_values, filter)
          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            retries += 1
            sleep 0.5
            retry unless retries > 2
            target = filter == :all ? 'element collection' : 'element'
            raise LocatorException, "Unable to locate #{target} from #{@selector} due to changing page"
          end
        end

        def locate_element(how, what, scope = @query_scope.wd)
          scope.find_element(how, what)
        end

        def locate_elements(how, what, scope = @query_scope.wd)
          scope.find_elements(how, what)
        end
      end
    end
  end
end
