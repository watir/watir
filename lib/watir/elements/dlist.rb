module Watir
  class DList < HTMLElement
    def to_hash
      keys = dts.map(&:text)
      values = dds.map(&:text)

      Hash[keys.zip(values)]
    end
  end # DList
end # Watir
