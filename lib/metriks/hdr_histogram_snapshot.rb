require 'HDRHistogram'

module Metriks
  class HdrHistogramSnapshot
    attr_reader :hdr

    def initialize(hdr)
      @hdr = hdr
    end

    def value(quantile)
      raise ArgumentError, "quantile must be between 0.0 and 1.0" if quantile < 0.0 || quantile > 1.0

      @hdr.percentile(quantile*100)
    end

    def size
      @hdr.count
    end

    def median
      value(0.5)
    end

    def get_75th_percentile
      value(0.75)
    end

    def get_95th_percentile
      value(0.95)
    end

    def get_98th_percentile
      value(0.98)
    end

    def get_99th_percentile
      value(0.99)
    end

    def get_999th_percentile
      value(0.999)
    end
  end
end
