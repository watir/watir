if defined?(RSpec)
  TIMING_EXCEPTIONS = {
    raise_unknown_object_exception: Watir::Exception::UnknownObjectException,
    raise_no_matching_window_exception: Watir::Exception::NoMatchingWindowFoundException,
    raise_unknown_frame_exception: Watir::Exception::UnknownFrameException,
    raise_object_disabled_exception: Watir::Exception::ObjectDisabledException,
    raise_object_read_only_exception: Watir::Exception::ObjectReadOnlyException,
    raise_no_value_found_exception: Watir::Exception::NoValueFoundException
  }.freeze

  TIMING_EXCEPTIONS.each do |matcher, exception|
    RSpec::Matchers.define matcher do |message|
      match do |actual|
        original_timeout = Watir.default_timeout
        Watir.default_timeout = 0
        begin
          actual.call
          false
        rescue exception => ex
          raise exception, "expected '#{message}' to be included in: '#{ex.message}'" unless message.nil? || ex.message.include?(message)
          true
        ensure
          Watir.default_timeout = original_timeout
        end
      end

      failure_message do |_actual|
        "expected #{exception} but nothing was raised"
      end

      def supports_block_expectations?
        true
      end
    end
  end
end
