module Watir
  module Container
    class << self
      def add(method, &blk)
        define_method(method, &blk)
      end
    end

    def element_by_xpath(xpath)
      if e = wd.find_element(:xpath, xpath)
        Watir.element_class_for(e.tag_name).new(self, :element, e)
      else
        BaseElement.new(self, :xpath, xpath)
      end
    end

    def elements_by_xpath(xpath)
      # TODO: find the correct element class
      @driver.find_elements(:xpath, xpath).map do |e|
        Watir.element_class_for(e.tag_name).new(self, :element, e)
      end
    end

  end # Container
end # Watir