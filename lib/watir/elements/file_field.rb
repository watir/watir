module Watir
  class FileField < Input
    identifier :type => 'file'

    container_method  :file_field
    collection_method :file_fields

    def set(value)
      assert_exists

      @element.send_keys value
    end
  end
end