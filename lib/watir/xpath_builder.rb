module Watir
  class XPathBuilder

    class << self
      def build_from(selector)
        xpath = "//"
        xpath << (selector.delete(:tag_name) || '*').to_s

        idx = selector.delete(:index)
        # the remaining entries should be attributes
        xpath << "[" << selector.map { |key, val| "@#{key}=#{val.to_s.inspect}" }.join(" and ") << "]"

        if idx
          xpath << "[#{idx}]"
        end

        xpath
      end
    end

  end # XPathBuilder
end # Watir