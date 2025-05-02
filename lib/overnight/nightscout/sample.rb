# frozen_string_literal: true

require 'overnight/nightscout/sample/predictor'
require 'overnight/nightscout/sample/synchronizer'

module Overnight
  class Nightscout
    # aggregates salient data from Nightscout for display and analysis
    class Sample
      extend Forwardable
      def_delegators :@synchronizer, :mistimed?, :next_time

      def self.print_column_headers
        Printer.print_column_headers
      end

      def initialize(time, entries, device_statuses, status, treatments)
        @entries = entries
        @devices = device_statuses
        @status = status
        @synchronizer = Synchronizer.new(time, status.time, latest_entry.time)
        @treatments = treatments
      end

      def print_row
        entries = [latest_entry, *min_max(12)]
        Printer.print_row(@synchronizer.request_time, @status, entries, loop)
      end

      def print_transitions
        predictor = Predictor.new(consolidate_entry_ranges, @treatments)
        predictor.print_transitions
      end

      def stale?
        @synchronizer.missed_samples.positive?
      end

      private

      def categorize(entry)
        @status.categorize(entry.glucose)
      end

      def latest_entry
        @entries.first
      end

      def loop
        @devices.first
      end

      def min_max(count)
        loop.predicted.take(count).minmax
      end

      def group_entries_by_range
        entries = [latest_entry] + loop.predicted
        grouped = entries.slice_when { |a, b| categorize(a) != categorize(b) }
        grouped.map { [categorize(it.first), it] }
      end

      def consolidate_entry_ranges
        group_entries_by_range.map do |range, entries|
          duration = entries.last.time - entries.first.time + Synchronizer::LOOP_INTERVAL
          EntryRange.new(entries.first, range, duration)
        end
      end
    end
  end
end
