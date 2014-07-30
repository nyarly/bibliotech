require 'bibliotech/backups/file_record'
module BiblioTech
  module Backups
    class Pruner
      def initialize(path, name)
        @path = path, @name = name
        @schedules = []
      end

      def add_schedule(frequency, limit)
        @schedules << Scheduler.new(frequency, limit)
      end

      def go
        return if schedules.empty?

        list = PruneList.new(path, name).list
        schedules.each do |schedule|
          schedule.mark(list)
        end
        list.each do |record|
          unless record.keep?
            delete(record.path)
          end
        end
      end

      def delete(path)
        File.unlink(path)
      end
    end

    class PruneList
      TIMESTAMP_REGEX = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})_(?<hour>\d{2}):(?<minute>\d{2})/

      attr_accessor :path, :name

      def initialize(path, name)
        @path, @name = path, name
      end

      def list
        files = []
        Dir.new(path).each do |file|
          next if %w{. ..}.include?(file)
          file_record = build_record(file)
          if file_record.nil?
          else
            files << file_record
          end
        end
      end

      def name_timestamp_re
        name_re(TIMESTAMP_REGEX)
      end

      def name_re(also)
        /\A#{name}-#{also}\..*\z/
      end

      def build_record(file)
        if file =~ name_re(/.*/)
          if !(match = name_timestamp_re.match(file)).nil?
            timespec = %w{year month day hour minute}.map do |part|
              Integer(match[part])
            end
            parsed_time = Time::utc(*timespec)
            return FileRecord.new(File::join(path, file), parsed_time)
          else
            raise "File prefixed #{name} doesn't match #{name_timestamp_re.to_s}: #{File::join(path, file)}"
          end
        else
          if file !~ TIMESTAMP_REGEX
            warn "Stray file in backups directory: #{File::join(path, file)}"
            return nil
          end
        end
        return nil
      end
    end
  end
end
