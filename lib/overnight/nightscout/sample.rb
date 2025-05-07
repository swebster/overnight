# frozen_string_literal: true

require 'forwardable'
require 'overnight/nightscout/sample/predictor'

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
        entries = [latest_entry] + predicted_entries(12).minmax
        Printer.print_row(@synchronizer.request_time, @status, entries, loop)
      end

      def print_transitions
        print = EntryRange.method(:print_transition)
        EntryRange.each_transition(entry_ranges, &print)
      end

      def print_problems
        problems = Predictor.new(entry_ranges, @treatments).problems
        problems.each { |problem| puts "Warning: #{problem}" }
      end

      def stale?
        @synchronizer.missed_samples.positive?
      end

      private

      def categorize(entry)
        @status.categorize(entry.glucose)
      end

      def create_entry_ranges
        entries = [latest_entry] + predicted_entries(24)
        EntryRange.consolidate(entries, &method(:categorize))
      end

      def entry_ranges
        @entry_ranges ||= create_entry_ranges
      end

      def latest_entry
        @entries.first
      end

      def loop
        @devices.first
      end

      def predicted_entries(count)
        loop.predicted.take(count)
      end
    end
  end
end
