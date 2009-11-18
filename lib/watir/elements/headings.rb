module Watir

  class Heading < HTMLElement
    default_selector.clear
  end

  class H1 < Heading
    identifier         :tag_name => 'h1'
    container_method   :h1
    collection_method  :h1s
  end

  class H2 < Heading
    identifier         :tag_name => 'h2'
    container_method   :h2
    collection_method  :h2s
  end

  class H3 < Heading
    identifier         :tag_name => 'h3'
    container_method   :h3
    collection_method  :h3s
  end

  class H4 < Heading
    identifier         :tag_name => 'h4'
    container_method   :h4
    collection_method  :h4s
  end

  class H5 < Heading
    identifier         :tag_name => 'h5'
    container_method   :h5
    collection_method  :h5s
  end

  class H6 < Heading
    identifier         :tag_name => 'h6'
    container_method   :h6
    collection_method  :h6s
  end
end