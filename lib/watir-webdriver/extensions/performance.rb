require "ostruct"

module Watir

  # Adds helper for window.performance to Watir::Browser.
  #
  # This module is provided by an optional require:
  #
  #   require "watir-webdriver/extensions/performance"
  #
  # @see http://dev.w3.org/2006/webapi/WebTiming/
  #

  module PerformanceHelper

    def performance
      data = driver.execute_script("return window.performance || window.webkitPerformance || window.mozPerformance || window.msPerformance;")
      data && Performance.new(data)
    end

    class Performance
      attr_reader :timing, :navigation, :memory

      def initialize(data)
        @timing     = rubify data['timing'] || {}
        @navigation = rubify data['navigation'] || {}
        @memory     = rubify data['memory'] || {}
      end

      private

      def rubify(hash)
        result = {}

        hash.each do |k, v|
          if k =~ /^[A-Z_]+$/
            k = k.downcase
          elsif k =~ /(start|end)$/i && Fixnum === v
            v = ::Time.at(v / 1000)
          end

          result[k.snake_case] = v
        end

        OpenStruct.new(result)
      end

    end # Performance
  end # PerformanceHelper

  class Browser
    include PerformanceHelper
  end
end # Watir
