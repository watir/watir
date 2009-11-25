# encoding: utf-8
module Watir
  class SelectList < Select
    container_method  :select_list
    collection_method :select_lists

    def clear
      assert_exists
      @element.clear
    end

    def selected_options
      options.map { |e| e.text if e.selected? }.compact
    end

  end
end
