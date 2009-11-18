module Watir
  class XPathBuilder

    class << self
      def build_from(selectors)
        return if selectors.values.any? { |e| e.kind_of? Regexp }

        xpath = "//"
        xpath << (selectors.delete(:tag_name) || '*').to_s

        idx = selectors.delete(:index)

        # the remaining entries should be attributes
        unless selectors.empty?
          xpath << "[" << selectors.map { |key, val| "@#{key}=#{val.to_s.inspect}" }.join(" and ") << "]"
        end

        if idx
          xpath << "[#{idx + 1}]"
        end

        xpath
      end
    end

  end # XPathBuilder
end # Watir