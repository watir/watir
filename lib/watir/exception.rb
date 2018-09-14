module Watir
  module Exception
    class Error < StandardError; end

    # TODO: rename Object -> Element?
    class UnknownObjectException < Error; end
    class ObjectDisabledException < Error; end
    class ObjectReadOnlyException < Error; end
    class NoValueFoundException < Error; end
    class NoMatchingWindowFoundException < Error; end
    class UnknownFrameException < Error; end
    class LocatorException < Error; end
  end # Exception
end # Watir
