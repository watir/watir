module Watir
  module Scrolling
    def scroll
      Scroll.new(self)
    end
  end

  class Scroll
    def initialize(object)
      @object = object
    end

    # Scrolls by offset.
    # @param [Fixnum] left Horizontal offset
    # @param [Fixnum] top Vertical offset
    #
    def by(left, top)
      @object.browser.execute_script('window.scrollBy(arguments[0], arguments[1]);', Integer(left), Integer(top))
      self
    end

    #
    # Scrolls to specified location.
    # @param [Symbol] param
    #
    def to(param = :top)
      args = @object.is_a?(Watir::Element) ? element_scroll(param) : browser_scroll(param)
      raise ArgumentError, "Don't know how to scroll #{@object} to: #{param}!" if args.nil?

      @object.browser.execute_script(*args)
      self
    end

    private

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
        'window.scrollTo(window.outerWidth / 2, window.outerHeight / 2);'
      when :bottom, :end
        'window.scrollTo(0, document.body.scrollHeight);'
      when Array
        ['window.scrollTo(arguments[0], arguments[1]);', Integer(param[0]), Integer(param[1])]
      end
    end
  end
end
