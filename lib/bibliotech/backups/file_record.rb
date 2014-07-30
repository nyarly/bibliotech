module BiblioTech
  module Backups
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
