module Watir
  module Locators
    class Element
      class Validator
        def validate(element, tag_name)
          element.tag_name.downcase =~ /#{tag_name}/
        end
      end
    end
  end
end
