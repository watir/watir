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
        find_first_by_one
      else
        find_first_by_multiple
      end
    rescue WebDriver::Error::WebDriverError => wde
      $stderr.puts wde.inspect
      nil
    end

    def locate_all
      if @selector.size == 1
        find_all_by_one
      else
        find_all_by_multiple
      end
    end

    def find_first_by_one
      how, what = @selector.shift
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_first_by(how, what)
      else
        raise NotImplementedError, "find first by attribute/other"
      end
    end

    def find_all_by_one
      how, what = @selector.shift
      check_type how, what

      if WD_FINDERS.include?(how)
        wd_find_all_by(how, what)
      else
        raise NotImplementedError, "find all by attribute/other"
      end
    end

    def find_first_by_multiple
      selector = normalized_selector

      idx   = selector.delete(:index)
      xpath = selector[:xpath] || XPathBuilder.build_from(selector)

      if xpath
        # strings only, so we could build the xpath
        if idx
          @driver.find_elements(:xpath, xpath)[idx]
        else
          @driver.find_element(:xpath, xpath)
        end
      else
        # we have at least one regexp
        if idx
          wd_find_by_regexp_selector(selector, :select)[idx]
        else
          wd_find_by_regexp_selector(selector, :find)
        end
      end
    end

    def find_all_by_multiple
      selector = normalized_selector

      if selector.has_key? :index
        raise Error, "can't locate all elements by :index"
      end

      xpath = selector[:xpath] || XPathBuilder.build_from(selector)
      if xpath
        @driver.find_elements(:xpath, xpath)
      else
        wd_find_by_regexp_selector(selector, :select)
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

    def wd_find_by_regexp_selector(selector, method = :find)
      rx_selector = delete_regexps_from(selector)
      xpath = XPathBuilder.build_from(selector) || raise("internal error: unable to build xpath from #{@selector.inspect}")

      elements = @driver.find_elements(:xpath, xpath)
      elements.send(method) { |e| matches_selector(rx_selector, e) }
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

    def normalized_selector
      selector = {}

      @selector.each do |how, what|
        check_type(how, what)

        how, what = normalize_selector(how, what)
        selector[how] = what
      end

      selector
    end

    def normalize_selector(how, what)
      case how
      when :url
        [:href, what]
      else
        [how, what]
      end
    end

    def delete_regexps_from(selector)
      rx_selector = {}

      selector.dup.each do |how, what|
        next unless what.kind_of?(Regexp)
        rx_selector[how] = what
        selector.delete how
      end

      rx_selector
    end

    #
  end # ElementLocator
end # Watir
