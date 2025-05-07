# frozen_string_literal: true

require 'overnight/nightscout/sample/entry_range'
require 'overnight/nightscout/treatment'

module Overnight
  class Nightscout
    class Sample
      # generates alerts about predicted glycemic events
      class Predictor
        LOW_NOTICE    = 30 * 60 # notice period for predicted lows
        HIGH_NOTICE   = 15 * 60 # notice period for predicted highs
        LOW_DURATION  = 15 * 60 # max acceptable length of predicted lows
        HIGH_DURATION = 60 * 60 # max acceptable length of predicted highs

        def initialize(entry_ranges, treatments)
          raise Error, 'No glucose entries provided' if entry_ranges.empty?

          @entry_ranges = entry_ranges
          @treatments = treatments
        end

        def find_predicted(ranges)
          found = predicted.drop_while { !ranges.include?(it.range) }
          found.take_while { ranges.include?(it.range) }.to_a
        end

        def low_predicted?
          er = find_predicted(%i[low urgent_low])
          in_range_soon?(er, LOW_NOTICE) && exceeds_duration?(er, LOW_DURATION)
        end

        def high_predicted?
          er = find_predicted(%i[high urgent_high])
          in_range_soon?(er, HIGH_NOTICE) && exceeds_duration?(er, HIGH_DURATION)
        end

        private

        def latest
          @entry_ranges.first
        end

        def predicted
          @entry_ranges.lazy.drop(1)
        end

        def in_range_soon?(entry_ranges, notice_period)
          entry_ranges.any? && entry_ranges.first.time <= Time.now + notice_period
        end

        def exceeds_duration?(entry_ranges, max_duration)
          entry_ranges.sum { it.duration } > max_duration
        end
      end
    end
  end
end
