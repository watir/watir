# encoding: utf-8
module Watir
  class Table < HTMLElement
    
    def to_a
      assert_exists
      
      trs.inject [] do |res, row|
        res << row.tds.map { |cell| cell.text }
      end
    end
    
    def [](idx)
      row(:index, idx)
    end

  end # Table
end # Watir
