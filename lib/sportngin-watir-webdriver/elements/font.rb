module Watir
  module Container
    def font(*args)
      Font.new(self, extract_selector(args).merge(:tag_name => "font"))
    end
    
    def fonts(*args)
      FontCollection.new(self, extract_selector(args).merge(:tag_name => "font"))
    end
  end # Container
end # Watir