# encoding: utf-8
module Watir
  class SelectList < Select

    container_method  :select_list
    collection_method :select_lists

    def enabled?
      !disabled?
    end

    def clear
      assert_exists
      @element.clear
    end

    def includes?(str_or_rx)
      assert_exists
      options.any? { |e| str_or_rx === e.text }
    end

    def select(str_or_rx)
      assert_exists
      os = options.select { |e| str_or_rx === e.text }

      if os.empty?
        raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
      end

      os.each { |e| e.select unless e.selected? }
      os.first.text
    end

    def selected?(str_or_rx)
      assert_exists
      matches = options.select { |e| str_or_rx === e.text }
      if matches.empty?
        raise UnknownObjectExcpetion, "Unable to locate option matching #{str_or_rx.inspect}"
      end

      matches.any? { |e| e.selected? }
    end

    def value
      o = options.find { |e| e.selected? }
      return if o.nil?

      o.value
    end

    def selected_options
      assert_exists
      options.map { |e| e.text if e.selected? }.compact
    end

  end
end
