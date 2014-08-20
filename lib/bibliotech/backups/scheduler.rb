require 'bibliotech/backups/file_record'

module BiblioTech
  module Backups
    class Scheduler
      attr_accessor :frequency, :limit

      def initialize(frequency, limit)
        @frequency, @limit = frequency, limit
        @limit = nil if limit == "all"
      end

      def end_time(file_list)
        return Time.at(0) if file_list.empty?
        file_list.map{|record| record.timestamp}.max
      end

      def compute_start_time(file_list)
        limit_time = Time.at(0)
        return limit_time if file_list.empty?
        unless limit.nil?
          limit_time = end_time(file_list) - limit * freq_seconds
        end
        [limit_time, file_list.map{|record| record.timestamp}.min - range].max
      end

      def freq_seconds
        frequency * 60
      end

      def range
        freq_seconds / 2
      end

      def mark(file_list)
        time = end_time(file_list)
        start_time = compute_start_time(file_list)
        while time > start_time do
          closest = file_list.min_by do |record|
            (record.timestamp - time).abs
          end
          if (closest.timestamp - time).abs < range
            closest.keep = true
          end
          time -= freq_seconds
        end
        return file_list
      end
    end
  end
end
