# encoding: utf-8
module Watir
  class SelectList < Select
    include Watir::Exception

    container_method  :select_list
    collection_method :select_lists

    def enabled?
      !disabled?
    end

    def clear
      assert_exists

      raise Exception::Error, "you can only clear multi-selects" unless multiple?

      options.each do |o|
        o.toggle if o.selected?
      end
    end

    def includes?(str_or_rx)
      assert_exists
      options.any? { |e| str_or_rx === e.text }
    end

    def select(str_or_rx)
      if multiple?
        select_all_by :text, str_or_rx
      else
        select_first_by :text, str_or_rx
      end
    end

    def select_value(str_or_rx)
      if multiple?
        select_all_by :value, str_or_rx
      else
        select_first_by :value, str_or_rx
      end
    end

    def selected?(str_or_rx)
      assert_exists
      matches = options.select { |e| str_or_rx === e.text }

      if matches.empty?
        raise UnknownObjectException, "Unable to locate option matching #{str_or_rx.inspect}"
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

    private

    def select_all_by(how, str_or_rx)
      os = options.select { |e| str_or_rx === e.send(how) }

      if os.empty?
        raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
      end

      os.each { |e| e.select unless e.selected? }
      os.first.text
    end

    def select_first_by(how, str_or_rx)
      option = options.find { |e| str_or_rx === e.send(how) }

      if option.nil?
        raise NoValueFoundException, "#{str_or_rx.inspect} not found in select list"
      end

      option.select unless option.selected?
      option.text
    end

  end
end
