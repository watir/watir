module Watir
  module XpathSupport
    LITERAL_REGEXP = /\A([^\[\]\\^$.|?*+()]*)\z/

    def self.escape(value)
      if value.include? "'"
        parts = value.split("'", -1).map { |part| "'#{part}'" }
        string = parts.join(%(,"'",))

        "concat(#{string})"
      else
        "'#{value}'"
      end
    end

    def self.downcase(value)
      "translate(#{value},'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
    end

    def self.simple_regexp?(regex)
      return false if !regex.is_a?(Regexp) || regex.casefold? || regex.source.empty?

      regex.source =~ LITERAL_REGEXP
    end
  end # XpathSupport
end # Watir
