# frozen_string_literal: true

require 'forwardable'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/sample/synchronizer'
require 'overnight/nightscout/status'

module Overnight
  class Nightscout
    # aggregates salient data from Nightscout for display and analysis
    class Sample
      extend Forwardable
      def_delegators :@synchronizer, :mistimed?, :next_time

      def initialize(time, entries, device_statuses, status)
        @entries = entries
        @devices = device_statuses
        @status = status
        @synchronizer = Synchronizer.new(time, status.time, latest_entry.time)
      end

      def self.print_column_headers
        columns = %w[LocalDate Time NsTime BgTime BG Min Max IOB COB]
        puts format('%-10 8 8 8 4 4 4 5 4s'.gsub(' ', 's %-'), *columns)
      end

      def print_row # rubocop:disable Metrics/AbcSize
        s = @synchronizer.request_time.localtime.strftime('%F %T ')
        s << [@status, latest_entry].map { |x| x.time.localtime.strftime('%T ') }.join
        s << [latest_entry, *min_max(12)].map { |y| @status.format(y.glucose) }.join(' ')
        puts s << format(' %5.2f %4.1f', loop.iob, loop.cob)
      end

      private

      def latest_entry
        @entries.first
      end

      def loop
        @devices.first
      end

      def min_max(count)
        loop.predicted.first(count).minmax
      end
    end
  end
end
