module Watir
  module JSExecution
    #
    # Delegates script execution to Browser or IFrame.
    #
    def execute_script(script, *args)
      @query_scope.execute_script(script, *args)
    end

    #
    # Simulates JavaScript events on element.
    # Note that you may omit "on" from event name.
    #
    # @example
    #   browser.button(name: "new_user_button").fire_event :click
    #   browser.button(name: "new_user_button").fire_event "mousemove"
    #   browser.button(name: "new_user_button").fire_event "onmouseover"
    #
    # @param [String, Symbol] event_name
    #

    def fire_event(event_name)
      event_name = event_name.to_s.sub(/^on/, '').downcase

      element_call { execute_js :fireEvent, @element, event_name }
    end

    #
    # Flashes (change background color to a new color and back a few times) element.
    #
    # @example
    #   browser.li(id: 'non_link_1').flash
    #   browser.li(id: 'non_link_1').flash(color: "green", flashes: 3, delay: 0.05)
    #   browser.li(id: 'non_link_1').flash(color: "yellow")
    #   browser.li(id: 'non_link_1').flash(color: ["yellow", "green"])
    #   browser.li(id: 'non_link_1').flash(flashes: 4)
    #   browser.li(id: 'non_link_1').flash(delay: 0.1)
    #   browser.li(id: 'non_link_1').flash(:fast)
    #   browser.li(id: 'non_link_1').flash(:slow)
    #   browser.li(id: 'non_link_1').flash(:rainbow)
    #
    # @param [Symbol] preset :fast, :slow, :long or :rainbow for pre-set values
    # @param [String/Array] color what 'color' or [colors] to flash with
    # @param [Integer] flashes number of times element should be flashed
    # @param [Integer, Float] delay how long to wait between flashes
    #
    # @return [Watir::Element]
    #

    def flash(preset = :default, color: 'red', flashes: 10, delay: 0.1)
      presets = {
        fast: {delay: 0.04},
        slow: {delay: 0.2},
        long: {flashes: 5, delay: 0.5},
        rainbow: {flashes: 5, color: %w[red orange yellow green blue indigo violet]}
      }
      return flash(presets[preset]) unless presets[preset].nil?

      background_color = original_color = style('background-color')
      background_color = 'white' if background_color.empty?
      colors = Array(color).push(background_color)

      (colors * flashes).each do |next_color|
        element_call { execute_js(:backgroundColor, @element, next_color) }
        sleep(delay)
      end

      element_call { execute_js(:backgroundColor, @element, original_color) }

      self
    end

    #
    # Focuses element.
    # Note that Firefox queues focus events until the window actually has focus.
    #
    # @see http://code.google.com/p/selenium/issues/detail?id=157
    #

    def focus
      element_call { execute_js(:focus, @element) }
    end

    #
    # Returns inner HTML code of element.
    #
    # @example
    #   browser.div(id: 'shown').inner_html
    #   #=> "<div id=\"hidden\" style=\"display: none;\">Not shown</div><div>Not hidden</div>"
    #
    # @return [String]
    #

    def inner_html
      element_call { execute_js(:getInnerHtml, @element) }.strip
    end

    #
    # Returns inner Text code of element.
    #
    # @example
    #   browser.div(id: 'shown').inner_text
    #   #=> "Not hidden"
    #
    # @return [String]
    #

    def inner_text
      element_call { execute_js(:getInnerText, @element) }.strip
    end

    #
    # Returns outer (inner + element itself) HTML code of element.
    #
    # @example
    #   browser.div(id: 'shown').outer_html
    #   #=> "<div id=\"shown\"><div id=\"hidden\" style=\"display: none;\">Not shown</div><div>Not hidden</div></div>"
    #
    # @return [String]
    #

    def outer_html
      element_call { execute_js(:getOuterHtml, @element) }.strip
    end
    alias html outer_html

    #
    # Returns text content of element.
    #
    # @example
    #   browser.div(id: 'shown').text_content
    #   #=> "Not shownNot hidden"
    #
    # @return [String]
    #

    def text_content
      element_call { execute_js(:getTextContent, @element) }.strip
    end

    #
    # Selects text on page (as if dragging clicked mouse across provided text).
    #
    # @example
    #   browser.li(id: 'non_link_1').select_text('Non-link')
    #

    def select_text(str)
      element_call { execute_js :selectText, @element, str }
    end

    #
    # Selects text on page (as if dragging clicked mouse across provided text).
    #
    # @example
    #   browser.li(id: 'non_link_1').selected_text
    #

    def selected_text
      element_call { execute_js :selectedText }
    end
  end # JSExecution
end # Watir
