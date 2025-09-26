# frozen_string_literal: true

require 'overnight/nightscout/problem'
require 'overnight/nightscout/treatment'

module Overnight
  class Nightscout
    # generates alerts about predicted glycemic events
    class Predictor
      EMPTY_ARRAY = [].freeze
      # notice period for predicted lows
      LOW_NOTICE = 30 * 60
      # notice period for predicted highs
      HIGH_NOTICE = 15 * 60
      # max acceptable length of predicted lows
      LOW_DURATION = 15 * 60
      # max acceptable length of predicted highs
      HIGH_DURATION = 60 * 60
      # max age of carb corrections to consider as low treatments
      LOW_TREATMENT_WINDOW = 15 * 60

      def initialize(entry_ranges:, treatments:, high_override:)
        raise Error, 'No glucose entries provided'  unless entry_ranges&.any?
        raise Error, 'Invalid treatment collection' if treatments.nil?
        raise Error, 'Invalid high override name'   if high_override&.empty?

        # not nil, not empty
        @entry_ranges = entry_ranges

        # not nil, may be empty
        @treatments = treatments

        # may be nil, but not empty
        @high_override = high_override
      end

      def low_predicted?
        predicted_low.any?
      end

      def high_predicted?
        predicted_high.any?
      end

      def problem
        case @entry_ranges.first.range
        when :urgent_low then handle_low(:urgent)
        when :low then handle_low(:persistent)
        when :high then handle_high(:persistent)
        when :urgent_high then handle_high(:urgent)
        else handle_low(:predicted) || handle_high(:predicted)
        end
      end

      private

      def find_predicted(ranges)
        found = @entry_ranges.drop_while { !ranges.include?(it.range) }
        found.take_while { ranges.include?(it.range) }.to_a
      end

      def in_range_soon?(entry_ranges, notice_period)
        entry_ranges.any? && entry_ranges.first.time <= Time.now + notice_period
      end

      def exceeds_duration?(entry_ranges, max_duration)
        entry_ranges.sum(&:duration) > max_duration
      end

      def contains_urgent?(entry_ranges, urgent_range)
        entry_ranges.any? { it.range == urgent_range }
      end

      def problematic?(entry_ranges, notice_period, max_duration, urgent_range)
        in_range_soon?(entry_ranges, notice_period) && (
          exceeds_duration?(entry_ranges, max_duration) ||
          contains_urgent?(entry_ranges, urgent_range)
        )
      end

      def predicted_low
        er = find_predicted(%i[low urgent_low])
        problematic?(er, LOW_NOTICE, LOW_DURATION, :urgent_low) ? er : EMPTY_ARRAY
      end

      def predicted_high
        er = find_predicted(%i[high urgent_high])
        problematic?(er, HIGH_NOTICE, HIGH_DURATION, :urgent_high) ? er : EMPTY_ARRAY
      end

      def handle_low(type)
        er = predicted_low
        return nil if er.empty?

        # any urgent lows or untreated regular lows are problematic
        Problem.new(er, :low, type) if contains_urgent?(er, :urgent_low) || !low_treated?
      end

      def handle_high(type)
        er = predicted_high
        return nil if er.empty?

        # any urgent highs or untreated regular highs are problematic
        Problem.new(er, :high, type) if contains_urgent?(er, :urgent_high) || !high_treated?
      end

      def low_treated?
        any_treatment?(Treatment::CarbCorrection) do
          it.timestamp > Time.now - LOW_TREATMENT_WINDOW
        end
      end

      def high_treated?
        return false if @high_override.nil?

        any_treatment?(Treatment::TemporaryOverride) do
          it.name == @high_override && it.expiry > Time.now
        end
      end

      def any_treatment?(klass, &)
        @treatments.lazy.select { it.is_a?(klass) }.any?(&)
      end
    end
  end
end
