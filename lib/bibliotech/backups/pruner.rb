require 'bibliotech/backups/prune_list'
require 'bibliotech/backups/file_record'
module BiblioTech
  module Backups
    class Pruner
      def initialize(config)
        @config = config
      end

      def path
        @path ||= config.backups_dir
      end

      def name
        @path ||= config.backups_name
      end

      def schedules
        @schedules ||=
          [].tap do |array|
          config.each_prune_schedule do |frequency, limit|
            array << Scheduler.new(frequency, limit)
          end
          end
      end

      def backup_needed?(time)
        time - list.most_recent.timestamp < config.backup_frequency * 60
      end

      def list
        @list ||=
          begin
            list = PruneList.new(path, name).list
            schedules.each do |schedule|
              schedule.mark(list)
            end
            list
          end
      end

      def pruneable
        list.select do |record|
          !record.keep?
        end
      end

      def go
        return if schedules.empty?
        pruneable.each {|record| delete(record.path) }
      end

      def delete(path)
        File.unlink(path)
      end
    end
  end
end
