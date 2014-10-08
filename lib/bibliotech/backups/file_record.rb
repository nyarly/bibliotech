module BiblioTech
  module Backups
    class FileRecord
      attr_accessor :path, :timestamp, :keep, :scheduled_by

      def initialize(path, timestamp)
        @path, @timestamp = path, timestamp
        @keep = false
        @scheduled_by = []
      end

      def keep?
        !!@keep
      end

      def in_schedule(name)
        @scheduled_by << name
        @keep = true
      end
    end
  end
end
