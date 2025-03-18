# frozen_string_literal: true

require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/status'

module Overnight
  class Nightscout
    # aggregates salient data from Nightscout for display and analysis
    class Sample
      def initialize(time, entries, device_statuses, status)
        @time = time
        @entries = entries
        @devices = device_statuses
        @status = status
      end

      def self.print_column_headers
        columns = %w[LocalDate Time NsTime BgTime BG Min Max IOB COB]
        puts format('%-10 8 8 8 4 4 4 5 4s'.gsub(' ', 's %-'), *columns)
      end

      def print_row # rubocop:disable Metrics/AbcSize
        current = @entries.first
        loop = @devices.first
        min_max = loop.predicted.first(12).minmax

        s = @time.localtime.strftime('%F %T ')
        s << [@status, current].map { |x| x.time.localtime.strftime('%T ') }.join
        s << [current, *min_max].map { |y| @status.format(y.glucose) }.join(' ')
        puts s << format(' %5.2f %4.1f', loop.iob, loop.cob)
      end
    end
  end
end
