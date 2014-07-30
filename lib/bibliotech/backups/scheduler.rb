module BiblioTech
  module Backups
    class Scheduler
      attr_accessor :frequency, :limit

      def end_time(file_list)
        file_list.map{|record| record.timestamp}.max
      end

      def compute_start_time(file_list)
        limit_time = Time.at(0)
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

    class FileRecord
      attr_accessor :path, :timestamp, :keep

      def initialize(path, timestamp)
        @path, @timestamp = path, timestamp
        @keep = false
      end

      def keep?
        !!@keep
      end
    end
  end
end
