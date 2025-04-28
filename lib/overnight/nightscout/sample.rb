# frozen_string_literal: true

require 'forwardable'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/sample/printer'
require 'overnight/nightscout/sample/synchronizer'
require 'overnight/nightscout/status'
require 'overnight/nightscout/treatment'

module Overnight
  class Nightscout
    # aggregates salient data from Nightscout for display and analysis
    class Sample
      extend Forwardable
      def_delegators :@synchronizer, :mistimed?, :next_time
      Transition = Data.define(:from, :to, :entry)

      def initialize(time, entries, device_statuses, status, treatments)
        @entries = entries
        @devices = device_statuses
        @status = status
        @synchronizer = Synchronizer.new(time, status.time, latest_entry.time)
        @treatments = treatments
      end

      def self.print_column_headers
        Printer.print_column_headers
      end

      def stale?
        @synchronizer.missed_samples.positive?
      end

      def print_row
        entries = [latest_entry, *min_max(12)]
        Printer.print_row(@synchronizer.request_time, @status, entries, loop)
      end

      def print_transitions
        transitions(24).each do |t|
          puts "#{Printer.format_date_time(t.entry.time)} #{t.from} -> #{t.to}"
        end
      end

      private

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

      def transitions(count)
        entries = [latest_entry, *predictions(count)]
        categorized = entries.map { |e| @status.categorize(e.glucose) }
        cons = categorized.each_cons(2).with_index.reject { |(a, b), _i| a == b }
        cons.reduce([]) { |t, ((a, b), i)| t << Transition.new(a, b, entries[i + 1]) }
      end
    end
  end
end
