# frozen_string_literal: true

require 'overnight/nightscout/entry_range'

module Overnight
  class Nightscout
    # describes the situation in which expected data has not been received
    class NoData
      def initialize(minutes)
        @minutes = minutes
      end

      def priority = 0

      def to_s
        "No data for the last #{@minutes} minutes"
      end
    end

    # describes a problematic glycemic event
    class Problem
      VALID_CATEGORIES = %i[low high].freeze
      VALID_TYPES      = %i[predicted persistent urgent].freeze

      attr_reader :category, :type

      def initialize(entry_ranges, category, type)
        raise Error, 'Invalid category' unless VALID_CATEGORIES.include?(category)
        raise Error, 'Invalid type'     unless VALID_TYPES.include?(type)

        @entry_ranges = entry_ranges
        @category = category
        @type = type
      end

      def priority
        (@type == :urgent ? 1 : 0) + (@category == :low ? 1 : 0)
      end

      def to_s
        time = format_time(@entry_ranges.first)
        duration = (duration_seconds / 60).round
        min_max = format_min_max
        "#{@type.capitalize} #{@category} #{time} #{duration} minutes, #{min_max}"
      end

      private

      def format_time(entry)
        if @type == :predicted
          "at #{Printer.format_time(entry.time, with_seconds: false)} for"
        else
          'for next'
        end
      end

      def duration_seconds
        if @type == :urgent
          @entry_ranges.first.duration
        else
          @entry_ranges.sum(&:duration)
        end
      end

      def format_min_max
        if @category == :low
          min = @entry_ranges.min_by(&:min_entry)
          "falling to #{format_glucose_time(min.min_entry, min.range)}"
        else # :high
          max = @entry_ranges.max_by(&:max_entry)
          "rising to #{format_glucose_time(max.max_entry, max.range)}"
        end
      end

      def format_glucose_time(entry, range)
        glucose = Printer.format_glucose(entry.glucose, range)
        time = Printer.format_time(entry.time, with_seconds: false)
        "#{glucose} by #{time}"
      end
    end
  end
end
