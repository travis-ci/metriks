# frozen_string_literal: true

module Metriks::Reporter
  class ProcTitle
    def initialize(options = {})
      @rounding = options[:rounding] || 1
      @prefix   = options[:prefix]   || $PROGRAM_NAME.dup

      @interval  = options[:interval] || 5
      @on_error  = options[:on_error] || proc { |ex| }

      @metrics  = []
    end

    def add(name, suffix = nil, &block)
      @metrics << [name, suffix, block]
    end

    def empty?
      @metrics.empty?
    end

    def start
      @_start ||= Thread.new do
        loop do
          begin
            unless @metrics.empty?
              title = generate_title
              $0 = "#{@prefix} #{title}" if title && !title.empty?
            end
          rescue Exception => e
            begin
              @on_error[e]
            rescue StandardError
              nil
            end
          end
          sleep @interval
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

    protected

    def generate_title
      @metrics.collect do |name, suffix, block|
        val = block.call
        val = "%.#{@rounding}f" % val if val.is_a?(Float)

        "#{name}: #{val}#{suffix}"
      end.join(' ')
    end
  end
end
