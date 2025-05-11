# frozen_string_literal: true

require 'forwardable'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/predictor'
require 'overnight/nightscout/sample/synchronizer'
require 'overnight/nightscout/status'

module Overnight
  class Nightscout
    # aggregates salient data from Nightscout for display and analysis
    class Sample
      extend Forwardable
      def_delegators :@synchronizer, :mistimed?, :next_time

      def self.print_column_headers
        columns = %w[LocalDate Time NsTime BgTime BG Min Max IOB COB]
        puts format('%-10 8 8 8 4 4 4 5 4s'.gsub(' ', 's %-'), *columns)
      end

      def initialize(time, entries, device_statuses, status, treatments)
        @entries = entries
        @devices = device_statuses
        @status = status
        @synchronizer = Synchronizer.new(time, status.time, latest_entry.time)
        @treatments = treatments
      end

      def print_row # rubocop:disable Metrics/AbcSize
        entries = [latest_entry] + predicted_entries(12).minmax
        local_date = Printer.format_date_time(@synchronizer.request_time)
        times = Printer.format_times([@status, entries.first].map(&:time))
        glucose_values = entries.map { format_glucose(it) }.join(' ')
        iob = Printer.format_iob(loop.iob)
        cob = Printer.format_cob(loop.cob)
        puts "#{local_date} #{times} #{glucose_values} #{iob} #{cob}"
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

      def format_glucose(entry)
        Printer.format_glucose(entry.glucose, categorize(entry), fixed_width: true)
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
