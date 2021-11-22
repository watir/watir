module Watir
  module SearchContext
    #
    # Returns true if element exists.
    # Checking for staleness is deprecated
    #
    # @return [Boolean]
    #

    def exists?
      if located? && stale?
        reset!
      elsif located?
        return true
      end

      assert_exists
      true
    rescue Exception::UnknownObjectException, Exception::UnknownFrameException
      false
    end
    alias exist? exists?

    def assert_exists
      locate unless located?
      return if located?

      raise unknown_exception, "unable to locate: #{inspect}"
    end

    def wait_for_exists
      return if located? # Performance shortcut

      begin
        @query_scope.wait_for_exists unless @query_scope.is_a? Browser
        wait_until(element_reset: true, &:exists?)
      rescue Wait::TimeoutError
        msg = "timed out after #{Watir.default_timeout} seconds, waiting for #{inspect} to be located"
        raise unknown_exception, msg
      end
    end

    # TODO: - this will get addressed with Watir::Executor implementation
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity:
    # rubocop:disable Metrics/PerceivedComplexity::
    def element_call(precondition = nil, &block)
      caller = caller_locations(1, 1)[0].label
      already_locked = browser.timer.locked?
      browser.timer = Wait::Timer.new(timeout: Watir.default_timeout) unless already_locked

      begin
        check_condition(precondition, caller)
        Watir.logger.debug "-> `Executing #{inspect}##{caller}`"
        yield
      rescue unknown_exception => e
        element_call(:wait_for_exists, &block) if precondition.nil?
        raise unknown_exception, e.message + custom_message
      rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::NoSuchElementError
        reset!
        retry
        # TODO: - InvalidElementStateError is deprecated, so no longer calling `raise_disabled`
        # need a better way to handle this
      rescue Selenium::WebDriver::Error::ElementNotInteractableError
        raise_present unless browser.timer.remaining_time.positive?
        raise_present unless %i[wait_for_present wait_for_enabled wait_for_writable].include?(precondition)
        retry
      rescue Selenium::WebDriver::Error::NoSuchWindowError
        raise Exception::NoMatchingWindowFoundException, 'browser window was closed'
      ensure
        Watir.logger.debug "<- `Completed #{inspect}##{caller}`"
        browser.timer.reset! unless already_locked
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def check_condition(condition, caller)
      Watir.logger.debug "<- `Verifying precondition #{inspect}##{condition} for #{caller}`"
      begin
        condition.nil? ? assert_exists : send(condition)
        Watir.logger.debug "<- `Verified precondition #{inspect}##{condition || 'assert_exists'}`"
      rescue unknown_exception
        raise unless condition.nil?

        Watir.logger.debug "<- `Unable to satisfy precondition #{inspect}##{condition}`"
        check_condition(:wait_for_exists, caller)
      end
    end

    def unknown_exception
      Exception::UnknownObjectException
    end
  end
end
