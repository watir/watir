module Watir
  class FileField < Input
    identifier :type => 'file'
    
    container_method  :file_field
    collection_method :file_fields
  end
end