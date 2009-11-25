# encoding: utf-8
module Watir
  class Image < HTMLElement

    def file_created_date
      assert_exists
      raise NotImplementedError
    end

    def file_size
      assert_exists
      raise NotImplementedError
    end

    def loaded?
      assert_exists
      raise NotImplementedError
    end

    def save(path)
      assert_exists
    end

  end # Image
end # Watir
