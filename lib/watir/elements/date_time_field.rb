module Watir
  class DateTimeField < Input
    #
    # Enter the provided value.
    #

    def set!(date)
      date = ::Time.parse date if date.is_a?(String)

      message = "DateTimeField##{__callee__} only accepts instances of DateTime or Time"
      raise ArgumentError, message unless [DateTime, ::Time].include?(date.class)

      date_time_string = date.strftime('%Y-%m-%dT%H:%M')
      element_call(:wait_for_writable) { execute_js(:setValue, @element, date_time_string) }
    end
    alias set set!
    alias value= set
  end # DateTimeField

  module Container
    def date_time_field(*args)
      DateTimeField.new(self, extract_selector(args).merge(tag_name: 'input', type: 'datetime-local'))
    end

    def date_time_fields(*args)
      DateTimeFieldCollection.new(self, extract_selector(args).merge(tag_name: 'input', type: 'datetime-local'))
    end
  end # Container

  class DateTimeFieldCollection < InputCollection
    private

    def element_class
      DateTimeField
    end
  end # DateTimeFieldCollection
end # Watir
