module Watir
  class DateField < Input
    #
    # Enter the provided value.
    #

    def set!(date)
      date = Date.parse date if date.is_a?(String)

      message = "DateField##{__callee__} only accepts instances of Date or Time"
      raise ArgumentError, message unless [Date, ::Time].include?(date.class)

      date_string = date.strftime('%Y-%m-%d')
      element_call(:wait_for_writable) do
        execute_js(:setValue, @element, date_string)
        execute_js(:fireEvent, @element, :change)
      end
    end
    alias set set!
    alias value= set
  end # DateField

  module Container
    def date_field(opts = {})
      DateField.new(self, opts.merge(tag_name: 'input', type: 'date'))
    end

    def date_fields(opts = {})
      DateFieldCollection.new(self, opts.merge(tag_name: 'input', type: 'date'))
    end
  end # Container

  class DateFieldCollection < InputCollection
    private

    def element_class
      DateField
    end
  end # DateFieldCollection
end # Watir
