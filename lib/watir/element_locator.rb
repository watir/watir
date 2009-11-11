module Watir
  class ElementLocator
    include Watir::Exceptions

    WD_FINDERS =  [ :class, :class_name, :id, :link_text, :link,
                    :partial_link_text, :name, :tag_name, :xpath ]

    def initialize(driver, selector)
      @driver   = driver
      @selector = selector.dup
    end

    def locate
      if @selector.size == 1
        how, what = @selector.shift
        find_first_by(how, what)
      else
        raise @selector.inspect
      end
    rescue WebDriver::Error::WebDriverError
      nil
    end

    def find_first_by(how, what)
      check_type what

      if WD_FINDERS.include?(how)
        wd_find_first_by(how, what)
      else
        raise NotImplementedError, "find by attribute"
      end
    end

    def wd_find_first_by(how, what)
      if what.kind_of? String
        @driver.find_element(how, what)
      else
        elements = @driver.find_elements(:xpath, '//*')
        elements.find { |e| get =~ what }
      end
    end

    def wd_find_all_by(how, what)
      @driver.find_elements(how, what)
    end


    def check_type(what)
      unless [String, Regexp].any? { |t| what.kind_of? t }
        raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
      end
    end
    #
  end # ElementLocator
end # Watir
