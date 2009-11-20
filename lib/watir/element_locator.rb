module Watir
  class ElementLocator
    include Watir::Exceptions
    include Selenium

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
        find_by_multiple
      end
    rescue WebDriver::Error::WebDriverError => wde
      $stderr.puts wde.inspect
      nil
    end

    def find_first_by(how, what)
      check_type what

      if WD_FINDERS.include?(how)
        wd_find_first_by(how, what)
      else
        raise NotImplementedError, "find first by attribute/other"
      end
    end

    def find_all_by(how, what)
      check_type what

      if WD_FINDERS.include?(how)
        wd_find_all_by(how, what)
      else
        raise NotImplementedError, "find all by attribute/other"
      end
    end

    def wd_find_first_by(how, what)
      if what.kind_of? String
        @driver.find_element(how, what)
      else
        all_elements.find { |e| fetch_value(how, e) =~ what }
      end
    end

    def wd_find_all_by(how, what)
      if what.kind_of? String
        @driver.find_elements(how, what)
      else
        all_elements.select { |e| fetch_value(how, e) =~ what }
      end
    end

    def find_by_multiple
      @selector.each do |how, what|
        case how
        when :tag_name
          raise TypeError, "expected Symbol, got #{what.class}" unless what.kind_of?(Symbol)
        when :index
          raise TypeError, "expected Fixnum, got #{what.class}" unless what.kind_of?(Fixnum)
        else
          check_type what
        end
      end


      xpath = @selector[:xpath] || XPathBuilder.build_from(@selector)
      if xpath
        @driver.find_element(:xpath, xpath)
      else
        raise NotImplementedError, 'regexp locator support'
      end
    end


    def check_type(what)
      unless [String, Regexp].any? { |t| what.kind_of? t }
        raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
      end
    end

    def all_elements
      @driver.find_elements(:xpath, '//*')
    end

    def fetch_value(how, element)
      case how
      when :text
        element.text
      # others?
      else
        element.attribute(how) rescue "" # TODO: rescue specific exception
      end
    end

    #
  end # ElementLocator
end # Watir
