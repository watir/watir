# frozen_string_literal: true

# Source: https://github.com/teamcapybara/capybara/blob/xpath_regexp/lib/capybara/selector/regexp_disassembler.rb
require 'regexp_parser'

module Watir
  module Locators
    class Element
      class SelectorBuilder
        class RegexpDisassembler
          def initialize(regexp)
            @regexp = regexp
            @regexp_source = regexp.source
          end

          def substrings
            @substrings ||= begin
              strs = extract_strings(Regexp::Parser.parse(@regexp), [+''])
              strs.map!(&:downcase) if @regexp.casefold?
              strs.reject(&:empty?).uniq
            end
          end

          private

          def min_repeat(exp)
            exp.quantifier&.min || 1
          end

          def fixed_repeat?(exp)
            min_repeat(exp) == (exp.quantifier&.max || 1)
          end

          def optional?(exp)
            min_repeat(exp).zero?
          end

          def extract_strings(expression, strings)
            meta_set = %i[meta set]
            expression.each do |exp|
              if optional?(exp)
                strings.push(+'')
                next
              end
              if meta_set.include?(exp.type)
                strings.push(+'')
                next
              end
              if exp.terminal?
                case exp.type
                when :literal
                  strings.last << (exp.text * min_repeat(exp))
                when :escape
                  strings.last << (exp.char * min_repeat(exp))
                else
                  strings.push(+'')
                end
              else
                min_repeat(exp).times { extract_strings(exp, strings) }
              end
              strings.push(+'') unless fixed_repeat?(exp)
            end
            strings
          end
        end
      end
    end
  end
end
