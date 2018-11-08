require 'metriks/hdr_histogram_snapshot'
require 'HDRHistogram'

module Metriks
  class HdrHistogram
    def initialize(lowest = 0.001, highest = 60*60, precision_digits = 3)
      @lowest = lowest
      @highest = highest
      @precision_digits = precision_digits
      @hdr = ::HDRHistogram.new(
        @lowest,
        @highest,
        @precision_digits,
        multiplier: 0.001, unit: :ms
      )
      @sum = 0.0
    end

    def clear
      @hdr.reset
      @sum = 0.0
    end

    def flush_histogram
      clear
    end

    def count
      @hdr.count
    end

    def snapshot
      HdrHistogramSnapshot.new(
        @hdr.dup.merge!(@hdr)
      )
    end

    def update(value)
      @hdr.record(value)
      @sum += value
    end

    def sum
      @sum
    end

    def max
      @hdr.max
    end

    def min
      @hdr.min
    end

    def mean
      @hdr.mean
    end

    def stddev
      @hdr.stddev
    end

    def variance
      raise NotImplementedError
    end
  end
end
