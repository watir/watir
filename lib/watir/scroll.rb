# frozen_string_literal: true

module Watir
  module Scrolling
    def scroll
      Scroll.new(self)
    end
  end

  class Scroll
    def initialize(object)
      @driver = object.browser.wd
      @object = object
      @origin = nil
    end

    # Scrolls by offset.
    # @param [Fixnum] left Horizontal offset
    # @param [Fixnum] top Vertical offset
    #
    def by(left, top)
      if @origin
        @driver.action.scroll_from(@origin, left, top).perform
      else
        @object.browser.execute_script('window.scrollBy(arguments[0], arguments[1]);', Integer(left), Integer(top))
      end
      self
    end

    # Scrolls to specified location.
    # @param [Symbol] param
    #
    def to(param = :top)
      return scroll_to_element if param == :viewport

      args = @object.is_a?(Watir::Element) ? element_scroll(param) : browser_scroll(param)
      raise ArgumentError, "Don't know how to scroll #{@object} to: #{param}!" if args.nil?

      @object.browser.execute_script(*args)
      self
    end

    # Sets an origin point for a future scroll
    # @param [Integer] x_offset
    # @param [Integer] y_offset
    def from(x_offset = 0, y_offset = 0)
      @origin = if @object.is_a?(Watir::Element)
                  Selenium::WebDriver::WheelActions::ScrollOrigin.element(@object.we, x_offset, y_offset)
                else
                  Selenium::WebDriver::WheelActions::ScrollOrigin.viewport(x_offset, y_offset)
                end
      self
    end

    private

    def scroll_to_element
      @driver.action.scroll_to(@object.we).perform
    end

    def element_scroll(param)
      script = case param
               when :top, :start
                 'arguments[0].scrollIntoView();'
               when :center
                 <<-JS
                   var bodyRect = document.body.getBoundingClientRect();
                   var elementRect = arguments[0].getBoundingClientRect();
                   var left = (elementRect.left - bodyRect.left) - (window.innerWidth / 2);
                   var top = (elementRect.top - bodyRect.top) - (window.innerHeight / 2);
                   window.scrollTo(left, top);
                 JS
               when :bottom, :end
                 'arguments[0].scrollIntoView(false);'
               else
                 return nil
               end
      [script, @object]
    end

    def browser_scroll(param)
      case param
      when :top, :start
        'window.scrollTo(0, 0);'
      when :center
        y = '(document.body.scrollHeight - window.innerHeight) / 2 + document.body.getBoundingClientRect().top'
        "window.scrollTo(window.outerWidth / 2, #{y});"
      when :bottom, :end
        'window.scrollTo(0, document.body.scrollHeight);'
      when Array
        ['window.scrollTo(arguments[0], arguments[1]);', Integer(param[0]), Integer(param[1])]
      end
    end
  end
end
