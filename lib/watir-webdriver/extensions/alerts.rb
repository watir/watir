module Watir

  #
  # Module provided by optional require:
  #
  #   require "watir-webdriver/extensions/alerts"
  #

  module AlertHelper

    #
    # Overwrite window.alert()
    #
    # This method is provided by an optional require - API is subject to change.
    #
    # @example
    #   browser.alert do
    #     browser.button(:value => "Alert").click
    #   end #=> "the alert message"
    #

    def alert(&blk)
      execute_script "window.alert = function(msg) { window.lastAlert = msg; }"
      yield
      execute_script "return window.lastAlert"
    end

    #
    # Overwrite window.confirm()
    #
    # This method is provided by an optional require - API is subject to change.
    #
    # @example
    #   browser.confirm(true) do
    #     browser.button(:value => "Confirm").click
    #   end #=> "the confirm message"

    def confirm(bool, &blk)
      execute_script "window.confirm = function(msg) { window.lastConfirm = msg; return #{!!bool} }"
      yield
      execute_script "return window.lastConfirm"
    end

    #
    # Overwrite window.prompt()
    #
    # This method is provided by an optional require - API is subject to change.
    #
    # @example
    #   browser.prompt("hello") do
    #     browser.button(:value => "Prompt").click
    #   end #=> { :message => "foo", :default => "bar" }
    #

    def prompt(answer, &blk)
      execute_script "window.prompt = function(text, value) { window.lastPrompt = { message: text, default: value }; return #{answer.to_json}; }"
      yield
      result = execute_script "return window.lastPrompt"

      result && result.dup.each_key { |k| result[k.to_sym] = result.delete(k)}
      result
    end
  end

  class Browser
    include AlertHelper
  end

end
