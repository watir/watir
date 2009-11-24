module Watir
  class ElementCollection
    include Enumerable
    
    def initialize(parent, element_class)
      @parent, @element_class = parent, element_class
    end
    
    def each(&blk)
      to_a.each(&blk)
    end
    
    def length
      to_a.length
    end
    alias_method :size, :length
    
    def [](idx)
      to_a[idx]
    end
    
    def first
      to_a[0]
    end
    
    def last
      to_a[-1]
    end
    
    def to_a
      @elements ||= begin
        wd_elements = driver.find_elements(:tag_name, @element_class.default_selector[:tag_name])
        wd_elements.map { |e| @element_class.new(@parent, :element, e) }
      end
    end
    
    def driver
      @parent.driver
    end
  end # ElementCollection
end # Watir