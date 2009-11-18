module Watir
  
  class Heading < HTMLElement
    default_selector.clear
  end
  
  class H1 < Heading
    identifier         :tag_name => 'h1'
    container_method   :h1
    collection_methods :h1s
  end
  
  class H2 < Heading
    identifier         :tag_name => 'h2'
    container_method   :h2
    collection_methods :h2s
  end
  
  class H3 < Heading
    identifier         :tag_name => 'h3'
    container_method   :h3
    collection_methods :h3s
  end
  
  class H4 < Heading
    identifier         :tag_name => 'h4'
    container_method   :h4
    collection_methods :h4s
  end
  
  class H5 < Heading
    identifier         :tag_name => 'h5'
    container_method   :h5
    collection_methods :h5s
  end
  
  class H6 < Heading
    identifier         :tag_name => 'h6'
    container_method   :h6
    collection_methods :h6s
  end
end