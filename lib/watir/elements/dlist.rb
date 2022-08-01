module Watir
  class DList < HTMLElement
    def to_hash
      keys = dts.map(&:text)
      values = dds.map(&:text)

      keys.zip(values).to_h
    end
  end # DList
end # Watir
