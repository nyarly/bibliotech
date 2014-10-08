require 'logger'

module BiblioTech
  module Logging
    def self.logger
      return @logger
    end

    def self.logger=(value)
      @logger = value
    end

    def log
      return BiblioTech::Logging.logger
    end

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
