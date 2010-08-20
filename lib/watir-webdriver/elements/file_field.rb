# encoding: utf-8
module Watir
  class FileField < Input
    #
    # Set the file field to the given path
    #
    # @param [String] a value
    #

    def set(value)
      assert_exists
      value.gsub!(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
      @element.send_keys value
    end

    #
    # Return the value of this field
    #
    # @return [String]
    #

    def value
      # since 'value' is an attribute on input fields, we override this here
      assert_exists
      @element.value
    end
  end

  module Container
    def file_field(*selectors)
      FileField.new(self, {:tag_name => "input", :type => "file"}, selectors)
    end

    def file_fields(*selectors)
      FileFieldCollection.new(self, {:tag_name => "input", :type => "file"}, selectors)
    end
  end # Container

  class FileFieldCollection < InputCollection
    def element_class
      FileField
    end
  end # FileFieldCollection
end # Watir
