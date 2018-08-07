module Watir
  module Generator
    module Util
      module_function

      def classify(regexp, str)
        if str =~ regexp
          Regexp.last_match(1)
        else
          str
        end
      end

      def paramify(regexp, str)
        classify(regexp, str).snake_case
      end
    end # Util
  end # Generator
end # Watir
