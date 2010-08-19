module Watir
  class TrsCollection < ElementCollection

    private

    def locator_class
      @parent.kind_of?(Watir::Table) ? TableRowLocator : super
    end

  end # TrCollection
end # Watir
