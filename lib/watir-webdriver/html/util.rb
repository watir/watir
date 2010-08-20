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

      SPECIALS = {
        'img' => 'image'
      }

      def paramify(str)
        if SPECIALS.has_key?(str)
          SPECIALS[str]
        else
          classify(str).snake_case
        end
      end

    end # Util
  end # HTML
end # Watir

