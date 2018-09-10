module Watir
  class FileField < Input
    #
    # Set the file field to the given path
    #
    # @param [String] path
    # @raise [Errno::ENOENT] if the file doesn't exist
    #

    def set(path)
      raise Errno::ENOENT, path unless File.exist?(path)

      self.value = path
    end

    #
    # Sets the file field to the given path
    #
    # @param [String] path
    #

    def value=(path)
      path = path.gsub(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
      element_call { @element.send_keys path }
    end
  end # FileField

  module Container
    def file_field(*args)
      FileField.new(self, extract_selector(args).merge(tag_name: 'input', type: 'file'))
    end

    def file_fields(*args)
      FileFieldCollection.new(self, extract_selector(args).merge(tag_name: 'input', type: 'file'))
    end
  end # Container

  class FileFieldCollection < InputCollection
  end # FileFieldCollection
end # Watir
