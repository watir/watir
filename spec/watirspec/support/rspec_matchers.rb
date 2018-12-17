if defined?(RSpec)
  DEPRECATION_WARNINGS = %i[selector_parameters
                            element_cache
                            ready_state
                            caption
                            class_array
                            use_capabilities
                            visible_text
                            link_text
                            text_regexp
                            stale_exists
                            stale_visible
                            stale_present
                            select_by
                            value_button
                            wait_until_present
                            wait_while_present].freeze

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
        return 'unexpected exception in the custom matcher block' unless @stdout_message

        deprecations_found = @stdout_message[/WARN Watir \[DEPRECATION\] ([^.*\ ]*)/, 1]
        but_message = if deprecations_found.nil?
                        'no Warnings were found'
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
    unknown_object: Watir::Exception::UnknownObjectException,
    no_matching_window: Watir::Exception::NoMatchingWindowFoundException,
    unknown_frame: Watir::Exception::UnknownFrameException,
    object_disabled: Watir::Exception::ObjectDisabledException,
    object_read_only: Watir::Exception::ObjectReadOnlyException,
    no_value_found: Watir::Exception::NoValueFoundException,
    timeout: Watir::Wait::TimeoutError
  }.freeze

  TIMING_EXCEPTIONS.each do |matcher, exception|
    RSpec::Matchers.define "raise_#{matcher}_exception" do |message|
      match do |actual|
        original_timeout = Watir.default_timeout
        Watir.default_timeout = 0
        begin
          actual.call
          false
        rescue exception => ex
          return true if message.nil? || ex.message.match(message)

          raise exception, "expected '#{message}' to be included in: '#{ex.message}'"
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

    RSpec::Matchers.define "wait_and_raise_#{matcher}_exception" do |message = nil, timeout: 2|
      match do |actual|
        original_timeout = Watir.default_timeout
        Watir.default_timeout = timeout
        begin
          start_time = ::Time.now
          actual.call
          false
        rescue exception => ex
          finish_time = ::Time.now
          unless message.nil? || ex.message.match(message)
            raise exception, "expected '#{message}' to be included in: '#{ex.message}'"
          end

          @time_difference = finish_time - start_time
          @time_difference > timeout
        ensure
          Watir.default_timeout = original_timeout
        end
      end

      failure_message do
        if @time_difference
          "expected action to take more than provided timeout (#{timeout} seconds), " \
          "instead it took #{@time_difference} seconds"
        else
          "expected #{exception} but nothing was raised"
        end
      end

      def supports_block_expectations?
        true
      end
    end
  end

  RSpec::Matchers.define :execute_immediately do |timeout: 10|
    match do |actual|
      original_timeout = Watir.default_timeout
      Watir.default_timeout = timeout
      begin
        start_time = ::Time.now
        actual.call
        @time_difference = ::Time.now - start_time
        @time_difference < timeout
      ensure
        Watir.default_timeout = original_timeout
      end
    end

    failure_message_when_negated do
      "expected action to take more than provided timeout (#{timeout} seconds), " \
      "instead it took #{@time_difference} seconds"
    end

    failure_message do
      "expected action to take less than provided timeout (#{timeout} seconds), " \
      "instead it took #{@time_difference} seconds"
    end

    def supports_block_expectations?
      true
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
