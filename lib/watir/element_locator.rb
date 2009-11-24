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
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_first_by(how, what)
      else
        raise NotImplementedError, "find first by attribute/other"
      end
    end

    def find_all_by(how, what)
      check_type how, what

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
        check_type(how, what)
      end

      idx   = @selector.delete(:index)
      xpath = @selector[:xpath] || XPathBuilder.build_from(@selector)
      
      if xpath
        if idx
          @driver.find_elements(:xpath, xpath)[idx]
        else
          @driver.find_element(:xpath, xpath)
        end
      else
        if idx
          all_elements.select { |e| matches_selector(@selector, e) }[idx]
        else
          all_elements.find { |e| matches_selector(@selector, e) }
        end
      end
    end


    def check_type(how, what)
      case how
      when :index
        raise TypeError, "expected Fixnum, got #{what.class}" unless what.kind_of?(Fixnum)
      else
        unless [String, Regexp].any? { |t| what.kind_of? t }
          raise TypeError, "expected String or Regexp, got #{what.inspect}:#{what.class}"
        end
      end
    end

    def all_elements
      @all_elements ||= @driver.find_elements(:xpath, '//*')
    end

    def fetch_value(how, element)
      case how
      when :text
        element.text
      when :tag_name
        element.tag_name
      else
        element.attribute(how) rescue "" # TODO: rescue specific exception
      end
    end

    def matches_selector(selector, element)
      # p :start => selector
      selector.all? do |how, what|
        # p :comparing => [how, what], :to => fetch_value(how, element)
        what === fetch_value(how, element)
      end
    end

    #
  end # ElementLocator
end # Watir
