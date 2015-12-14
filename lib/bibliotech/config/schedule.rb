require 'bibliotech/backups/scheduler'
require 'bibliotech/backups/calendar_scheduler'

module BiblioTech
  class Config
    class Schedules
      def initialize(config)
        @config = config
      end
      attr_reader :config

      SCHEDULE_SHORTHANDS = {
        "hourly"      => 60,
        "hourlies"    => 60,
        "daily"       => 60 * 24,
        "dailies"     => 60 * 24,
        "weekly"      => 60 * 24 * 7,
        "weeklies"    => 60 * 24 * 7,
        "monthly"     => 60 * 24 * 30,
        "monthlies"   => 60 * 24 * 30,
        "quarterly"   => 60 * 24 * 120,
        "quarterlies" => 60 * 24 * 120,
        "yearly"      => 60 * 24 * 365,
        "yearlies"    => 60 * 24 * 365,
      }.freeze
      def regularize_frequency(frequency)
        Integer( SCHEDULE_SHORTHANDS.fetch(frequency){ frequency } )
      rescue ArgumentError
        raise "#{frequency.inspect} is neither a number of minutes or a shorthand. Try:\n  #{SCHEDULE_SHORTHANDS.keys.join(" ")}"
      end

      def backup_frequency
        @backup_frequency ||= regularize_frequency(config.local_get(:backup_frequency))
      end

      def regularize_schedule(freq)
        regularize_frequency(freq)
      end

      def schedules
        config_hash.map do |frequency, limit|
          next if limit == "none"
          real_frequency = regularize_schedule(frequency)
          limit =
            case limit
            when "all"
              nil
            else
              Integer(limit)
            end
          [frequency, real_frequency, limit]
        end.compact.map do |config_frequency, regularized, limit|
          build_scheduler(config_frequency, regularized, limit).tap do |sched|
            unless sched.frequency % backup_frequency == 0
              raise "Pruning frequency #{sched.frequency}:#{config_frequency} is not a multiple " +
              "of backup frequency: #{backup_frequency}:#{config.local_get(:backup_frequency)}"
            end
          end
        end.compact.sort_by do |schedule|
          schedule.frequency
        end
      end

      def get_config_hash(name)
        value = config.local_get(name)
        if value.to_s == "none"
          return {}
        else
          return value
        end
      end
    end

    class Periods < Schedules
      def config_hash
        hash = {}

        config.optionally{ hash.merge! get_config_hash(:prune_schedule) }
        config.optionally{ hash.merge! get_config_hash(:legacy_prune_schedule) }
        hash
      end

      def build_scheduler(frequency, real_frequency, limit)
        Backups::Scheduler.new(frequency, real_frequency, limit)
      end
    end

    class Calendars < Schedules
      def config_hash
        hash = {}
        config.optionally{ hash = get_config_hash(:prune_calendar) }
        [:quarterly, :quarterlies, "quarterly", "quarterlies"].each do |qkey|
          limit = hash.delete(qkey)
          if limit
            hash.merge!(
              :first_quarter => limit,
              :second_quarter => limit,
              :third_quarter => limit,
              :fourth_quarter => limit
            )
          end
        end
        hash
      end

      def regularize_schedule(freq)
        case freq
        when Array
          freq
        when "daily", "dailies", :daily, :dailies
          [ 0, 00 ]
        when "monthly", "monthlies", :monthly, :monthlies
          [ 1, 0, 00 ] # on the 1st, at 0:00
        when "first_quarter", "first-quarter", :first_quarter
          [ 1, 1, 0, 00 ] # on the 1st of Jan, at 0:00
        when "second_quarter", "second-quarter", :second_quarter
          [ 4, 1, 0, 00 ] # on the 1st of Apr, at 0:00
        when "third_quarter", "third-quarter", :third_quarter
          [ 7, 1, 0, 00 ] # on the 1st of Jul, at 0:00
        when "fourth_quarter", "fourth-quarter", :fourth_quarter
          [ 10, 1, 0, 00 ] # on the 1st of Oct, at 0:00
        end
      end

      def build_scheduler(frequency, schedule_pattern, limit)
        Backups::CalendarScheduler.new(schedule_pattern, limit)
      end
    end
  end
end
