require 'bibliotech/backups/prune_list'
require 'bibliotech/backups/file_record'
require 'bibliotech/logger'

module BiblioTech
  module Backups
    class Pruner
      include Logging
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
        @schedules ||= config.prune_schedules
      end

      def frequency
        @frequency ||= config.backup_frequency
      end

      def backup_needed?(time)
        most_recent = most_recent()
        log.info{ "backup_needed?: most_recent is #{most_recent.path rescue "<nil>"}" }
        if most_recent.nil?
          log.warn{ "backup_needed?: no backups yet -> YES" }
          return true
        end

        difference = time - most_recent.timestamp
        freq_seconds = frequency * 60
        if difference >= freq_seconds
          log.warn{ "backup_needed?: check time: #{time.inspect} most_recent timestamp: #{most_recent.timestamp.inspect}" }
          log.warn{ "backup_needed?: delta: #{difference} frequency: #{freq_seconds} -> YES" }
          return true
        else
          log.info{ "backup_needed?: check time: #{time.inspect} most_recent timestamp: #{most_recent.timestamp.inspect}" }
          log.info{ "backup_needed?: delta: #{difference} frequency: #{freq_seconds} -> NO" }
          return false
        end
      end

      def list
        @list ||= PruneList.new(path, name).list
      end

      def mark_list
        schedules.each do |schedule|
          schedule.mark(list)
        end
      end

      def most_recent
        list.max_by do |record|
          record.timestamp
        end
      end

      def filename_for(time)
        PruneList.filename_for(name, time)
      end

      def pruneable
        mark_list
        if list.empty?
          log.warn{ "No backup files in #{path} / #{name} !" }
        end
        list.each do |record|
          if record.keep
            log.info{ "#{record.path} #{record.timestamp} kept: #{record.scheduled_by.inspect}" }
          else
            log.warn{ "#{record.path} #{record.timestamp} discarding" }
          end
        end
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
