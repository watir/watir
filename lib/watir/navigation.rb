module Watir
  module Navigation
    #
    # Goes to the given URL.
    #
    # @example
    #   browser.goto "watir.github.io"
    #
    # @param [String] uri The url.
    # @return [String] The url you end up at.
    #

    def goto(uri)
      uri = "http://#{uri}" unless uri =~ URI::DEFAULT_PARSER.make_regexp

      @driver.navigate.to uri
      @after_hooks.run

      uri
    end

    #
    # Navigates back in history.
    #

    def back
      @driver.navigate.back
      @after_hooks.run
    end

    #
    # Navigates forward in history.
    #

    def forward
      @driver.navigate.forward
      @after_hooks.run
    end

    #
    # Refreshes current page.
    #

    def refresh
      @driver.navigate.refresh
      @after_hooks.run
    end
  end # Navigation
end # Watir
