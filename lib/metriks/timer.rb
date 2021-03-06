require 'atomic'
require 'hitimes'

require 'metriks/meter'
require 'metriks/histogram'

module Metriks
  class Timer
    class Context
      def initialize(timer)
        @timer    = timer
        @interval = Hitimes::Interval.now
      end

      def restart
        @interval = Hitimes::Interval.now
      end

      def stop
        @interval.stop
        @timer.update(@interval.duration)
      end
    end

    def initialize(histogram = Metriks::Histogram.new_exponentially_decaying)
      @meter     = Metriks::Meter.new
      @histogram = histogram
      @count     = 0
    end

    def clear
      @meter.clear
      @histogram.clear
      @count = 0
    end

    def flush_histogram
      @histogram.flush_histogram if @histogram.respond_to?(:flush_histogram)
    end

    def update(duration)
      if duration >= 0
        @meter.mark
        @histogram.update(duration)
        @count += 1
      end
    end

    def time(callable = nil, &block)
      callable ||= block
      context = Context.new(self)

      if callable.nil?
        return context
      end

      begin
        return callable.call
      ensure
        context.stop
      end
    end

    def snapshot
      @histogram.snapshot
    end

    def count
      @count
    end

    def sum
      @histogram.sum
    end

    def one_minute_rate
      @meter.one_minute_rate
    end

    def five_minute_rate
      @meter.five_minute_rate
    end

    def fifteen_minute_rate
      @meter.fifteen_minute_rate
    end

    def mean_rate
      @meter.mean_rate
    end

    def min
      @histogram.min
    end

    def max
      @histogram.max
    end

    def mean
      @histogram.mean
    end

    def stddev
      @histogram.stddev
    end

    def stop
      @meter.stop
    end
  end
end
