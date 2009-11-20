module Watir
  class TextField < Input
    identifier :type => 'text' # a text field is the default for input elements, so this needs to be changed

    container_method  :text_field
    collection_method :text_fields

    def set(*args)
      assert_exists
      @element.send_keys(*args)
    end
  end
end