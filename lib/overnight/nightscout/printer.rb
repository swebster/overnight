# frozen_string_literal: true

require 'overnight/nightscout/device_status'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/status'

module Overnight
  class Nightscout
    # provides methods to print various sample details to $stdout
    module Printer
      module_function

      def print_column_headers
        columns = %w[LocalDate Time NsTime BgTime BG Min Max IOB COB]
        puts format('%-10 8 8 8 4 4 4 5 4s'.gsub(' ', 's %-'), *columns)
      end

      def print_row(request_time, status, entries, device_status)
        local_date = format_date_time(request_time)
        times = format_times([status, entries.first].map(&:time))
        glucose_values = entries.map { status.format(it.glucose) }.join(' ')
        iob = format_iob(device_status.iob)
        cob = format_cob(device_status.cob)
        puts "#{local_date} #{times} #{glucose_values} #{iob} #{cob}"
      end

      def format_date_time(time)
        time.localtime.strftime('%F %T')
      end

      def format_time(time)
        time.localtime.strftime('%T')
      end

      def format_times(times)
        times.map { format_time(it) }.join(' ')
      end

      def format_glucose(glucose)
        format('%.1f', glucose / 18.0)
      end

      def format_iob(iob)
        format('%5.2f', iob)
      end

      def format_cob(cob)
        format('%4.1f', cob)
      end
    end
  end
end
