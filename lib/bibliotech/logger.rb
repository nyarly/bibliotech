require 'logger'

module BiblioTech
  module Logging
    class NullLogger < BasicObject
      def method_missing(method, *args, &block)
      end
    end

    def self.logger
      return (@logger || null_logger)
    end

    def self.null_logger
      @null_logger ||=
        begin
          warn "Logging to a NullLogger (because logger didn't get set up)"
          NullLogger.new
        end
    end

    def self.logger=(value)
      @logger = value
    end

    def log
      return BiblioTech::Logging.logger
    end
    module_function :log

    def self.log_level(string)
      case string
      when /fatal/i
        Logger::FATAL
      when /error/i
        Logger::ERROR
      when /warn/i
        Logger::WARN
      when /info/i
        Logger::INFO
      when /debug/i
        Logger::DEBUG
      else
        Logger::DEBUG
      end
    end
  end

end
