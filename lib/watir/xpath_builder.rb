module Watir
  class XPathBuilder

    class << self
      def build_from(selector)
        return if selector.values.any? { |e| e.kind_of? Regexp }
          
        xpath = "//"
        xpath << (selector.delete(:tag_name) || '*').to_s

        idx = selector.delete(:index)
        
        # the remaining entries should be attributes
        unless selector.empty?
          xpath << "[" << selector.map { |key, val| "@#{key}=#{val.to_s.inspect}" }.join(" and ") << "]"
        end

        if idx
          xpath << "[#{idx + 1}]"
        end

        xpath
      end
    end

  end # XPathBuilder
end # Watir