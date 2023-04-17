# frozen_string_literal: true

module Watir
  class DateTimeField < Input
    #
    # Enter the provided value.
    #

    def set!(date)
      date = ::Time.parse date if date.is_a?(String)

      message = "DateTimeField##{__callee__} only accepts instances that respond to #strftime"
      raise ArgumentError, message unless date.respond_to?(:strftime)

      date_time_string = date.strftime('%Y-%m-%dT%H:%M')
      element_call(:wait_for_writable) do
        execute_js(:setValue, @element, date_time_string)
        execute_js(:fireEvent, @element, :change)
      end
    end
    alias set set!
    alias value= set
  end # DateTimeField

  module Container
    def date_time_field(opts = {})
      DateTimeField.new(self, opts.merge(tag_name: 'input', type: 'datetime-local'))
    end

    def date_time_fields(opts = {})
      DateTimeFieldCollection.new(self, opts.merge(tag_name: 'input', type: 'datetime-local'))
    end
  end # Container

  class DateTimeFieldCollection < InputCollection
    private

    def element_class
      DateTimeField
    end
  end # DateTimeFieldCollection
end # Watir
