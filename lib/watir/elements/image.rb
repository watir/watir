module Watir
  class Image < HTMLElement

    def file_created_date
      raise NotImplementedError
    end

    def file_size
      raise NotImplementedError
    end
    
    def loaded?
      raise NotImplementedError
    end
    
    def save(path)
      
    end

  end # Image
end # Watir
