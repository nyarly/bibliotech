require 'bibliotech/backups/prune_list'
require 'bibliotech/backups/file_record'
require 'bibliotech/backups/scheduler'

module BiblioTech
  module Backups
    class Pruner
      def initialize(config)
        @config = config
      end
      attr_reader :config

      def path
        @path ||= config.backup_path
      end

      def name
        @name ||= config.backup_name
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
        most_recent = most_recent()
        return true if most_recent.nil?
        time - most_recent.timestamp < config.backup_frequency * 60
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

      def most_recent
        list.max_by do |record|
          record.timestamp
        end
      end

      def filename_for(time)
        PruneList.filename_for(config.backup_name, time)
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
