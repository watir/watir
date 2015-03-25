module Watir
  class DList < HTMLElement

    def to_hash
      keys = dts.map { |e| e.text }
      values = dds.map { |e| e.text }

      Hash[keys.zip(values)]
    end

  end # DList
end # Watir
