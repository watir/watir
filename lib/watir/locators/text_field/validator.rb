module Watir
  module Locators
    class TextField
      class Validator < Element::Validator
        def validate(element, _tag_name)
          # Zero for Ruby 2.3, Ruby 2.4+ this evaluates true/false
          result = element.tag_name.casecmp('input')
          result.zero? || result.eq(true)
        end
      end
    end
  end
end
