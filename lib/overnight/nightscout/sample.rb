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
        predictor = Predictor.new(first_in_each_range(24), @treatments)
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
        predictions(count).minmax
      end

      def predictions(count)
        loop.predicted.take(count)
      end

      def first_in_each_range(count)
        entries = [latest_entry, *predictions(count)]
        categorized = entries.map { EntryRange.new(it, categorize(it)) }
        categorized.slice_when { |a, b| a.range != b.range }.map(&:first)
      end
    end
  end
end
