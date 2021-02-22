require 'forwardable'
require 'logger'

# Code adapted from Selenium Implementation
# https://github.com/SeleniumHQ/selenium/blob/trunk/rb/lib/selenium/webdriver/common/logger.rb

module Watir
  #
  # @example Enable full logging
  #   Watir.logger.level = :debug
  #
  # @example Log to file
  #   Watir.logger.output = 'watir.log'
  #
  # @example Use logger manually
  #   Watir.logger.info('This is info message')
  #   Watir.logger.warn('This is warning message')
  #
  class Logger
    extend Forwardable
    include ::Logger::Severity

    def_delegators :@logger, :debug, :debug?,
                   :info, :info?,
                   :warn?,
                   :error, :error?,
                   :fatal, :fatal?,
                   :level, :level=

    def initialize(progname = 'Watir')
      @logger = create_logger($stdout)
      @logger.progname = progname
      @ignored = []
    end

    def ignore(ids)
      @ignored.concat Array(ids).map(&:to_s)
    end

    def output=(io)
      @logger.reopen(io)
    end

    #
    # Only log a warn message if it is not set to be ignored.
    #
    def warn(message, ids: [], &block)
      msg = ids.empty? ? '' : "[#{ids.map!(&:to_s).map(&:inspect).join(', ')}] "
      msg += message
      @logger.warn(msg, &block) unless (@ignored & ids).any?
    end

    #
    # Returns IO object used by logger internally.
    #
    # Normally, we would have never needed it, but we want to
    # use it as IO object for all child processes to ensure their
    # output is redirected there.
    #
    # It is only used in debug level, in other cases output is suppressed.
    #
    # @api private
    #
    def io
      @logger.instance_variable_get(:@logdev).instance_variable_get(:@dev)
    end

    #
    # Marks code as deprecated with replacement.
    #
    # @param [String] old
    # @param [String] new
    #
    def deprecate(old, new, reference: '', ids: [])
      return if @ignored.include?('deprecations') || (@ignored & ids.map!(&:to_s)).any?

      msg = ids.empty? ? '' : "[#{ids.map(&:inspect).join(', ')}] "
      ref_msg = reference.empty? ? '.' : "; see explanation for this deprecation: #{reference}."
      warn "[DEPRECATION] #{msg}#{old} is deprecated. Use #{new} instead#{ref_msg}"
    end

    def selenium=(val)
      Selenium::WebDriver.logger.level = val
    end

    private

    def create_logger(output)
      logger = ::Logger.new(output)
      logger.progname = 'Watir'
      logger.level = ($DEBUG ? DEBUG : WARN)
      logger.formatter = proc do |severity, time, progname, msg|
        "#{time.strftime('%F %T')} #{severity} #{progname} #{msg}\n"
      end

      logger
    end
  end
end
