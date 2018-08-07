if defined?(RSpec)
  DEPRECATION_WARNINGS = [:selector_parameters,
                          :class_array,
                          :use_capabilities,
                          :visible_text,
                          :text_regexp,
                          :stale_visible,
                          :stale_present,
                          :select_by].freeze

  DEPRECATION_WARNINGS.each do |deprecation|
    RSpec::Matchers.define "have_deprecated_#{deprecation}" do
      match do |actual|
        warning = /\[DEPRECATION\] \["#{deprecation}"\]/
        expect {
          actual.call
          @stdout_message = File.read $stdout if $stdout.is_a?(File)
        }.to output(warning).to_stdout_from_any_process
      end

      failure_message do |_actual|
        deprecations_found = @stdout_message[/WARN Watir \[DEPRECATION\] ([^.*\ ]*)/, 1]
        but_message = if deprecations_found.nil?
                        "no Warnings were found"
                      else
                        "deprecation Warning of #{deprecations_found} was found instead"
                      end
        "expected Warning message of \"#{deprecation}\" being deprecated, but #{but_message}"
      end

      def supports_block_expectations?
        true
      end
    end
  end

  TIMING_EXCEPTIONS = {
    raise_unknown_object_exception: Watir::Exception::UnknownObjectException,
    raise_no_matching_window_exception: Watir::Exception::NoMatchingWindowFoundException,
    raise_unknown_frame_exception: Watir::Exception::UnknownFrameException,
    raise_object_disabled_exception: Watir::Exception::ObjectDisabledException,
    raise_object_read_only_exception: Watir::Exception::ObjectReadOnlyException,
    raise_no_value_found_exception: Watir::Exception::NoValueFoundException,
    raise_timeout_exception: Watir::Wait::TimeoutError
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
          raise exception, "expected '#{message}' to be included in: '#{ex.message}'" unless message.nil? || ex.message.match(message)
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

  RSpec::Matchers.define :exist do |*args|
    match do |actual|
      actual.exists?(*args)
    end

    failure_message do |obj|
      "expected #{obj.inspect} to exist"
    end

    failure_message_when_negated do |obj|
      "expected #{obj.inspect} to not exist"
    end
  end

end
