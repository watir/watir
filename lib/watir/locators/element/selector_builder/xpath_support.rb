module Watir
  module Locators
    class Element
      class SelectorBuilder
        module XpathSupport
          # TODO: Switch to more comprehensive list
          UPPERCASE_ALL = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ'.freeze
          LOWERCASE_ALL = 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ'.freeze

          UPPERCASE_LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.freeze
          LOWERCASE_LETTERS = 'abcdefghijklmnopqrstuvwxyz'.freeze

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
            "translate(#{value}, '#{UPPERCASE_LETTERS}', '#{LOWERCASE_LETTERS}')"
          end
        end
      end
    end
  end # XpathSupport
end # Watir
