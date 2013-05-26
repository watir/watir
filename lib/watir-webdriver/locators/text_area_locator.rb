module Watir
  class TextAreaLocator < ElementLocator

    private

    def normalize_selector(how, what)
      # We need to iterate through located elements and fetch
      # attribute value using WebDriver because XPath doesn't understand
      # difference between IDL vs content attribute.
      # Current ElementLocator design doesn't allow to do that in any
      # obvious way except to use regular expression.
      if how == :value && what.kind_of?(String)
        [how, Regexp.new('^' + Regexp.escape(what) + '$')]
      else
        super
      end
    end

  end # TextAreaLocator
end # Watir
