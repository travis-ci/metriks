# frozen_string_literal: true

module Metriks::Reporter
  class Riemann
    require 'riemann/client'

    attr_accessor :client

    def initialize(options = {})
      @client = ::Riemann::Client.new(
        host: options[:host],
        port: options[:port]
      )
      @registry = options[:registry] || Metriks::Registry.default
      @interval = options[:interval] || 60
      @on_error = options[:on_error] || proc { |ex| }

      @default_event = options[:default_event] || {}
      @default_event[:ttl] ||= @interval * 1.5
    end

    def start
      @_start ||= Thread.new do
        loop do
          sleep @interval

          Thread.new do
            write
          rescue Exception => e
            begin
              @on_error[e]
            rescue StandardError
              nil
            end
          end
        end
      end
    end

    def stop
      @thread&.kill
      @thread = nil
    end

    def restart
      stop
      start
    end

    def flush
      # Is this supposed to take interval into account? --aphyr
      return unless !@last_write || @last_write.min != Time.now.min

      write
    end

    def write
      @last_write = Time.now

      @registry.each do |name, metric|
        case metric
        when Metriks::Meter
          send_metric name, 'meter', metric, %i[
            count one_minute_rate five_minute_rate
            fifteen_minute_rate mean_rate
          ]
        when Metriks::Counter
          send_metric name, 'counter', metric, [
            :count
          ]
        when Metriks::Gauge
          send_metric name, 'gauge', metric, [
            :value
          ]
        when Metriks::UtilizationTimer
          send_metric name, 'utilization_timer', metric, %i[
            count one_minute_rate five_minute_rate
            fifteen_minute_rate mean_rate
            min max mean stddev
            one_minute_utilization five_minute_utilization
            fifteen_minute_utilization mean_utilization
          ], %i[
            median get_95th_percentile
          ]
        when Metriks::Timer
          send_metric name, 'timer', metric, %i[
            count one_minute_rate five_minute_rate
            fifteen_minute_rate mean_rate
            min max mean stddev
          ], %i[
            median get_95th_percentile
          ]
        when Metriks::Histogram, Metriks::HdrHistogram
          send_metric name, 'histogram', metric, %i[
            count min max mean stddev
          ], %i[
            median get_95th_percentile
          ]
        end

        metric.flush_histogram if metric.respond_to?(:flush_histogram)
      end
    end

    def send_metric(name, type, metric, keys, snapshot_keys = [])
      keys.each do |key|
        @client << @default_event.merge(
          service: "#{name} #{key}",
          metric: metric.send(key),
          tags: [type]
        )
      end

      return if snapshot_keys.empty?

      snapshot = metric.snapshot
      snapshot_keys.each do |key|
        @client << @default_event.merge(
          service: "#{name} #{key}",
          metric: snapshot.send(key),
          tags: [type]
        )
      end
    end
  end
end
