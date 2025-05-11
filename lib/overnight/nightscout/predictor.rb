# frozen_string_literal: true

require 'overnight/nightscout/entry_range'
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

      def initialize(entry_ranges, treatments)
        raise Error, 'No glucose entries provided' if entry_ranges.empty?

        @entry_ranges = entry_ranges
        @treatments = treatments
      end

      def low_predicted?
        predicted_low.any?
      end

      def high_predicted?
        predicted_high.any?
      end

      def problems
        case @entry_ranges.first.range
        when :urgent_low then handle_low(:urgent)
        when :low then handle_low(:persistent)
        when :high then handle_high(:persistent)
        when :urgent_high then handle_high(:urgent)
        else handle_low(:predicted) || handle_high(:predicted)
        end || EMPTY_ARRAY
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
        entry_ranges.sum { it.duration } > max_duration
      end

      def problematic?(entry_ranges, notice_period, max_duration)
        in_range_soon?(entry_ranges, notice_period) &&
          exceeds_duration?(entry_ranges, max_duration)
      end

      def predicted_low
        er = find_predicted(%i[low urgent_low])
        problematic?(er, LOW_NOTICE, LOW_DURATION) ? er : EMPTY_ARRAY
      end

      def predicted_high
        er = find_predicted(%i[high urgent_high])
        problematic?(er, HIGH_NOTICE, HIGH_DURATION) ? er : EMPTY_ARRAY
      end

      def handle_low(type)
        er = predicted_low
        [format_problem(er, :low, type)] unless er.empty? || low_treated?
      end

      def handle_high(type)
        er = predicted_high
        [format_problem(er, :high, type)] unless er.empty? || high_treated?
      end

      def format_problem(entry_ranges, problem, type)
        time = format_time(entry_ranges, type)
        duration = (get_duration(entry_ranges, type) / 60).round
        min_max = format_min_max(entry_ranges, problem)
        "#{type.capitalize} #{problem} #{time} #{duration} minutes, #{min_max}"
      end

      def format_time(entry_ranges, type)
        if type == :predicted
          "at #{Printer.format_time(entry_ranges.first.time)} for"
        else
          'for next'
        end
      end

      def get_duration(entry_ranges, type)
        if type == :urgent
          entry_ranges.first.duration
        else
          entry_ranges.sum { it.duration }
        end
      end

      def format_min_max(entry_ranges, problem)
        if problem == :low
          min = entry_ranges.min_by(&:min_entry)
          "falling to #{format_glucose_time(min.min_entry, min.range)}"
        else # :high
          max = entry_ranges.max_by(&:max_entry)
          "rising to #{format_glucose_time(max.max_entry, max.range)}"
        end
      end

      def format_glucose_time(entry, range)
        glucose = Printer.format_glucose(entry.glucose, range)
        time = Printer.format_time(entry.time)
        "#{glucose} by #{time}"
      end

      def low_treated?
        false
      end

      def high_treated?
        false
      end
    end
  end
end
