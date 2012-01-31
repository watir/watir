# encoding: utf-8
module Watir
  module XpathSupport

    def self.escape(value)
      if value.include? "'"
        parts = value.split("'", -1).map { |part| "'#{part}'" }
        string = parts.join(%{,"'",})

        "concat(#{string})"
      else
        "'#{value}'"
      end
    end

  end # XpathSupport
end # Watir
