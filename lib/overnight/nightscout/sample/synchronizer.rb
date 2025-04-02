# frozen_string_literal: true

module Overnight
  class Nightscout
    class Sample
      # adjusts sample timing to request data ASAP after it becomes available
      class Synchronizer
        attr_reader :request_time, :server_time, :sample_time

        def initialize(request_time, server_time, sample_time)
          @request_time = request_time
          @server_time = server_time
          @sample_time = sample_time
        end

        def mistimed?
          !delay.between?(self.class.minimum_delay, self.class.maximum_delay)
        end

        def missed_samples
          ((server_time - sample_time) / self.class.loop_interval).floor.clamp(0..)
        end

        def next_sample
          sample_time + self.class.loop_interval * (missed_samples + 1)
        end

        def next_time
          next_sample - latency + self.class.target_delay
        end

        def self.target_delay
          (minimum_delay + maximum_delay) / 2.0
        end

        def self.loop_interval = 300.0
        def self.minimum_delay =  10.0
        def self.maximum_delay =  20.0

        private

        def latency
          server_time - request_time
        end

        def delay
          (server_time - sample_time) % self.class.loop_interval
        end
      end
    end
  end
end
