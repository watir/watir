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

    def alert(&blk)
      warn 'AlertHelper is deprecated. Use the new Alert API instead (e.g. browser.alert.ok)'
      execute_script "window.alert = function(msg) { window.__lastWatirAlert = msg; }"
      yield
      execute_script "return window.__lastWatirAlert"
    end

    #
    # Overwrite window.confirm()
    #
    # This method is provided by an optional require - API is subject to change.
    #

    def confirm(bool, &blk)
      warn 'AlertHelper is deprecated. Use the new Alert API instead (e.g. browser.alert.ok)'
      execute_script "window.confirm = function(msg) { window.__lastWatirConfirm = msg; return #{!!bool} }"
      yield
      execute_script "return window.__lastWatirConfirm"
    end

    #
    # Overwrite window.prompt()
    #
    # This method is provided by an optional require - API is subject to change.
    #

    def prompt(answer, &blk)
      warn 'AlertHelper is deprecated. Use the new Alert API instead (e.g. browser.alert.ok)'
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
