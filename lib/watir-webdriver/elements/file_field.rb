# encoding: utf-8
module Watir
  class FileField < Input
    def self.from(parent, element)
      if element.attribute(:type) != "file"
        raise TypeError, "expected type=file for #{element.inspect}"
      end

      super
    end

    #
    # Set the file field to the given path
    #
    # @param [String] a path
    #
    # @raise [Errno::ENOENT] if the file doesn't exist
    #

    def set(path)
      raise Errno::ENOENT, path unless File.exist?(path)
      self.value = path
    end

    #
    # Set the file field to the given path
    #
    # @param [String] a path
    #
    def value=(path)
      assert_exists
      path = path.gsub(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
      @element.send_keys path
    end

    #
    # Return the value of this field
    #
    # In IE, the path returned depends on the "Include local directory path
    # when uploading files to a server" security setting:
    #
    # @see http://msdn.microsoft.com/en-us/library/ms535128(VS.85).aspx
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
    def file_field(*args)
      FileField.new(self, extract_selector(args).merge(:tag_name => "input", :type => "file"))
    end

    def file_fields(*args)
      FileFieldCollection.new(self, extract_selector(args).merge(:tag_name => "input", :type => "file"))
    end
  end # Container

  class FileFieldCollection < InputCollection
    def element_class
      FileField
    end
  end # FileFieldCollection
end # Watir
