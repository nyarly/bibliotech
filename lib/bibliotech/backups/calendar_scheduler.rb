require 'bibliotech/backups/scheduler'

module BiblioTech
  module Backups
    class CalendarScheduler < Scheduler
      # pattern is an array with minutes rightmost
      def initialize(pattern, limit)
        @pattern = pattern
        super(name_for(pattern), freq_for(pattern), limit)
      end
      attr_accessor :pattern

      def name_for(pattern)
        example_time = coerce(Time.new, pattern)
        case pattern.length
        when 0
          "every-minute"
        when 1
          example_time.strftime('Hourly at :%M')
        when 2
          example_time.strftime('Daily at %H:%M')
        when 3
          example_time.strftime('Monthly on day %d, at %H:%M')
        when 4
          example_time.strftime('Yearly: %b %d, at %H:%M')
        else
          raise ArgumentError, "argument out of range"
        end

      end

      def freq_for(pattern)
        case pattern.length
        when 0
          1
        when 1
          60
        when 2
          60 * 24
        when 3
          60 * 24 * 28
        when 4
          60 * 24 * 365
        else
          raise ArgumentError, "argument out of range"
        end
      end

      def adjustment_index
        5 - pattern.length
      end

      # [sec, min, hour, day, month, year, wday, yday, isdst, zone]
      # new(year, month, day, hour, min, sec, utc_offset)
      def coerce(time, pat=pattern)
        existing = time.to_a
        changeable = existing[((pat.length+1)..5)].reverse
        values = changeable + pat + [0, time.utc_offset]
        Time.new(*values) + 1
      end

      def compute_earliest_time(file_list)
        exact_time = super
        time = coerce(exact_time)
        if time < exact_time
          time
        else
          step_back(time)
        end
      end

      def latest_time(file_list)
        exact_time = super
        time = coerce(exact_time)
        if time > exact_time
          time
        else
          step_forward(time)
        end
      end

      def step_back(time)
        coerce(super(time))
      end

      def step_forward(time)
        coerce(super(time))
      end
    end
  end
end
