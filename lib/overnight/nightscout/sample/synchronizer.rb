# frozen_string_literal: true

require 'overnight/nightscout/constants'

module Overnight
  class Nightscout
    class Sample
      # adjusts sample timing to request data ASAP after it becomes available
      class Synchronizer
        LOOP_INTERVAL = Constants::LOOP_INTERVAL
        MINIMUM_DELAY =  10.0
        MAXIMUM_DELAY =  20.0
        TARGET_DELAY  = (MINIMUM_DELAY + MAXIMUM_DELAY) / 2.0

        attr_reader :request_time, :server_time, :sample_time

        def initialize(request_time, server_time, sample_time)
          @request_time = request_time
          @server_time = server_time
          @sample_time = sample_time
        end

        def mistimed?
          !delay.between?(MINIMUM_DELAY, MAXIMUM_DELAY)
        end

        def missed_samples
          ((server_time - sample_time) / LOOP_INTERVAL).floor.clamp(0..)
        end

        def next_sample
          sample_time + LOOP_INTERVAL * (missed_samples + 1)
        end

        def next_time
          next_sample - latency + TARGET_DELAY
        end

        private

        def latency
          server_time - request_time
        end

        def delay
          (server_time - sample_time) % LOOP_INTERVAL
        end
      end
    end
  end
end
