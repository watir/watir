module Watir
  module Exceptions

    # TODO: rename Object -> Element?
    class UnknownObjectException < StandardError; end
    class ObjectDisabledException < StandardError; end
    class ObjectReadOnlyException < StandardError; end
    class NoValueFoundException < StandardError; end
    class MissingWayOfFindingObjectException < StandardError; end
    class UnknownCellException < StandardError; end
    class NoMatchingWindowFoundException < StandardError; end
    class NoStatusBarException < StandardError; end
    class NavigationException < StandardError; end

  end # Exceptions
end # Watir
