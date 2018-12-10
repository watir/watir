module Watir
  class RadioSet
    extend Forwardable
    include Exception
    include Enumerable

    delegate %i[exists? present? visible? browser] => :source

    attr_reader :source, :frame

    def initialize(query_scope, selector)
      raise ArgumentError, "invalid argument: #{selector.inspect}" unless selector.is_a? Hash

      @source = Radio.new(query_scope, selector)
      @frame = @source.parent(tag_name: 'form')
    end

    #
    # Yields each Radio associated with this set.
    #
    # @example
    #   radio_set = browser.radio_set
    #   radio_set.each do |radio|
    #     puts radio.text
    #   end
    #
    # @yieldparam [Watir::RadioSet] element iterate through the radio buttons.
    #

    def each(&block)
      radios.each(&block)
    end

    #
    # Get the n'th radio button in this set
    #
    # @return Watir::Radio
    #

    def [](idx)
      radios[idx]
    end

    #
    # @return Watir::Radio
    #

    def radio(opt = {})
      if !name.empty? && (!opt[:name] || opt[:name] == name)
        frame.radio(opt.merge(name: name))
      elsif name.empty?
        source
      else
        raise UnknownObjectException, "#{opt[:name]} does not match name of RadioSet: #{name}"
      end
    end

    #
    # @return Watir::RadioCollection
    #

    def radios(opt = {})
      if !name.empty? && (!opt[:name] || opt[:name] == name)
        element_call(:wait_for_present) { frame.radios(opt.merge(name: name)) }
      elsif name.empty?
        single_radio_collection
      else
        raise UnknownObjectException, "#{opt[:name]} does not match name of RadioSet: #{name}"
      end
    end

    #
    # Returns true if any radio buttons in the set are enabled.
    #
    # @return [Boolean]
    #

    def enabled?
      any?(&:enabled?)
    end

    #
    # Returns true if all radio buttons in the set are disabled.
    #
    # @return [Boolean]
    #

    def disabled?
      !enabled?
    end

    #
    # Returns the name attribute for the set.
    #
    # @return [String]
    #

    def name
      @name ||= source.name
    end

    #
    # If RadioSet exists, this always returns 'radio'.
    #
    # @return [String]
    #

    def type
      assert_exists
      'radio'
    end

    #
    # Returns true if the radio set has one or more radio buttons where label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @return [Boolean]
    #

    def include?(str_or_rx)
      radio(label: str_or_rx).exist?
    end

    #
    # Select the radio button whose value or label matches the given string.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::UnknownObjectException] if the Radio does not exist.
    # @return [String] The value or text of the radio selected.
    #

    def select(str_or_rx)
      %i[value label].each do |key|
        radio = radio(key => str_or_rx)
        next unless radio.exist?

        radio.click unless radio.selected?
        return key == :value ? radio.value : radio.text
      end
      raise UnknownObjectException, "Unable to locate radio matching #{str_or_rx.inspect}"
    end

    #
    # Returns true if any of the radio button label matches the given value.
    #
    # @param [String, Regexp] str_or_rx
    # @raise [Watir::Exception::UnknownObjectException] if the options do not exist
    # @return [Boolean]
    #

    def selected?(str_or_rx)
      found = frame.radio(label: str_or_rx)
      return found.selected? if found.exist?

      raise UnknownObjectException, "Unable to locate radio matching #{str_or_rx.inspect}"
    end

    #
    # Returns the value of the selected radio button in the set.
    # Returns nil if no radio is selected.
    #
    # @return [String, nil]
    #

    def value
      selected&.value
    end

    #
    # Returns the text of the selected radio button in the set.
    # Returns nil if no option is selected.
    #
    # @return [String, nil]
    #

    def text
      selected&.text
    end

    #
    # Returns the selected Radio element.
    # Returns nil if no radio button is selected.
    #
    # @return [Watir::Radio, nil]
    #

    def selected
      find(&:selected?)
    end

    #
    # Returns true if two elements are equal.
    #
    # @example
    #   browser.radio_set(id: 'new_user_newsletter_yes') == browser.radio_set(id: 'new_user_newsletter_no')
    #   #=> true
    #

    def ==(other)
      other.is_a?(self.class) && radios == other.radios
    end
    alias eql? ==

    # Ruby 2.4+ complains about using #delegate to do this
    %i[assert_exists element_call].each do |method|
      define_method(method) do |*args, &blk|
        source.send(method, *args, &blk)
      end
    end

    private

    def single_radio_collection
      collection = RadioCollection.new(frame, source.selector)
      collection.first.cache = source.wd
      collection
    end
  end # RadioSet

  module Container
    def radio_set(*args)
      RadioSet.new(self, extract_selector(args).merge(tag_name: 'input', type: 'radio'))
    end

    Watir.tag_to_class[:radio_set] = RadioSet
  end # Container
end # Watir
