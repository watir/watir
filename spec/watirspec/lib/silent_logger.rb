require "logger"

module WatirSpec
  class SilentLogger
    (::Logger.instance_methods - Object.instance_methods).each do |logger_instance_method|
      define_method(logger_instance_method) { |*args| }          
    end
  end
end

