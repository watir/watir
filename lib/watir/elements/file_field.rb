# encoding: utf-8
module Watir
  class FileField < Input
    identifier :type => 'file'

    container_method  :file_field
    collection_method :file_fields

    def set(value)
      assert_exists
      @element.send_keys value
    end

    def value
      # since 'value' is an attribute on input fields, we override this here
      assert_exists
      @element.value
    end
  end
end
