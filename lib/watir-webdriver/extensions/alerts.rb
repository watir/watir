module Watir

  #
  # Deprecated, use the new Alert API instead.
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
      warn 'AlertHelper is deprecated. Use the new Alert API instead (e.g. browser.alert.close)'
      execute_script "window.alert = function(msg) { window.__lastWatirAlert = msg; }"
      yield
      execute_script "return window.__lastWatirAlert"
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
      warn 'AlertHelper is deprecated. Use the new Alert API instead (e.g. browser.confirm.close)'
      execute_script "window.confirm = function(msg) { window.__lastWatirConfirm = msg; return #{!!bool} }"
      yield
      execute_script "return window.__lastWatirConfirm"
    end

    #
    # Overwrite window.prompt()
    #
    # This method is provided by an optional require - API is subject to change.
    #
    # @example
    #   browser.prompt("hello") do
    #     browser.button(:value => "Prompt").click
    #   end #=> { :message => "foo", :default_value => "bar" }
    #

    def prompt(answer, &blk)
      warn 'AlertHelper is deprecated. Use the new Alert API instead (e.g. browser.prompt.close)'
      execute_script "window.prompt = function(text, value) { window.__lastWatirPrompt = { message: text, default_value: value }; return #{MultiJson.encode answer}; }"
      yield
      result = execute_script "return window.__lastWatirPrompt"

      result && result.dup.each_key { |k| result[k.to_sym] = result.delete(k)}
      result
    end
  end

  class Browser
    include AlertHelper
  end

end
