module Watir
  module Locators
    class Element
      class Locator
        include Exception

        attr_reader :element_matcher, :driver_scope

        def initialize(element_matcher)
          @query_scope = element_matcher.query_scope
          @selector = element_matcher.selector
          @element_matcher = element_matcher
        end

        def locate(built)
          @built = built.dup
          @driver_scope = locator_scope.wd
          @filter = :first
          matching_elements
        rescue Selenium::WebDriver::Error::NoSuchElementError
          nil
        end

        def locate_all(built)
          @built = built.dup
          @driver_scope = locator_scope.wd
          @filter = :all

          return [matching_elements].flatten unless @built.key?(:index)

          raise ArgumentError, "can't locate all elements by :index"
        end

        private

        def matching_elements
          return locate_element(*@built.to_a.flatten) if @built.size == 1 && @filter == :first

          # TODO: Wrap this to continue trying until default timeout
          retries = 0
          begin
            elements = locate_elements(*wd_locator.to_a.flatten)

            element_matcher.match(elements, match_values, @filter)
          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            retries += 1
            sleep 0.5
            retry unless retries > 2
            target = @filter == :all ? 'element collection' : 'element'
            raise LocatorException, "Unable to locate #{target} from #{@selector} due to changing page"
          end
        end

        def wd_locator
          # SelectorBuilder only allows one of these
          wd_locator_key = (Watir::Locators::W3C_FINDERS & @built.keys).first
          @wd_locator ||= @built.select { |k, _v| wd_locator_key == k }
        end

        def match_values
          @match_values ||= @built.reject { |k, _v| wd_locator.keys.first == k }
        end

        def locator_scope
          scope = @built.delete(:scope)
          @locator_scope ||= scope || @query_scope.browser
        end

        def locate_element(how, what, scope = driver_scope)
          scope.find_element(how, what)
        end

        def locate_elements(how, what, scope = driver_scope)
          scope.find_elements(how, what)
        end
      end
    end
  end
end
