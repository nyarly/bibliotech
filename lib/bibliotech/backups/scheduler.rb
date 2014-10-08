require 'bibliotech/backups/file_record'

module BiblioTech
  module Backups
    class Scheduler
      attr_accessor :frequency, :limit, :name

      def initialize(frequency, limit)
        @name = frequency
        @frequency, @limit = frequency, limit
        @limit = nil if limit == "all"
      end

      def freq_seconds
        frequency * 60
      end

      def range
        freq_seconds / 2
      end

      # The earliest possible time to keep a file in.
      def compute_earliest_time(file_list)
        limit_time = Time.at(0)
        return limit_time if file_list.empty?
        unless limit.nil?
          limit_time = latest_time(file_list) - limit * freq_seconds
        end
        [limit_time, file_list.last.timestamp - range].max
      end

      # The latest possible time to keep a file in.
      def latest_time(file_list)
        return Time.at(0) if file_list.empty?
        file_list.first.timestamp
      end

      # Working from the latest time backwards, mark the closest file to the
      # appropriate frequencies as keepable
      def mark(original_file_list)
        file_list = original_file_list.sort_by{|record| -record.timestamp.to_i} #sort from newest to oldest

        time = latest_time(file_list)
        earliest_time = compute_earliest_time(file_list)
        while time > earliest_time do
          file_list.delete_if do |record|
            record.timestamp > time
          end

          break if file_list.empty?

          closest = file_list.first

          if (time - closest.timestamp) < freq_seconds
            closest.in_schedule(name)
          end
          time -= freq_seconds
        end
        return original_file_list
      end
    end
  end
end
