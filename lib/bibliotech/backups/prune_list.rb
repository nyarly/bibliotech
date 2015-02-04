module BiblioTech
  module Backups
    class PruneList
      TIMESTAMP_REGEX = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})_(?<hour>\d{2}):(?<minute>\d{2})/

      attr_accessor :path, :prefix

      def initialize(path, prefix)
        @path, @prefix = path, prefix
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
        files.sort_by do |record|
          - record.timestamp.to_i
        end
      end

      def prefix_timestamp_re
        prefix_re(TIMESTAMP_REGEX)
      end

      def prefix_re(also)
        /\A#{prefix}-#{also}\..*\z/
      end

      def self.filename_for(prefix, time)
        time.strftime("#{prefix}-%Y-%m-%d_%H:%M.sql")
      end

      def build_record(file)
        if file =~ prefix_re(/.*/)
          if !(match = prefix_timestamp_re.match(file)).nil?
            timespec = %w{year month day hour minute}.map do |part|
              Integer(match[part], 10)
            end
            parsed_time = Time::utc(*timespec)
            return FileRecord.new(File::join(path, file), parsed_time)
          else
            raise "File prefixed #{prefix} doesn't match #{prefix_timestamp_re.inspect}: #{File::join(path, file)}"
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
