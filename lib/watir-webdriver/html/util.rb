module Watir
  module HTML
    module Util

      module_function

      def classify(name)
        if name =~ /^HTML(.+)Element$/
          $1
        else
          name
        end
      end

      def paramify(str)
        classify(str).snake_case
      end

    end # Util
  end # HTML
end # Watir

