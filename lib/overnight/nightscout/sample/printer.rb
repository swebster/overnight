# frozen_string_literal: true

module Overnight
  class Nightscout
    class Sample
      # provides methods to print various sample details to $stdout
      module Printer
        module_function

        def print_column_headers
          columns = %w[LocalDate Time NsTime BgTime BG Min Max IOB COB]
          puts format('%-10 8 8 8 4 4 4 5 4s'.gsub(' ', 's %-'), *columns)
        end

        def print_row(request_time, status, entries, loop)
          local_date = format_date_time(request_time)
          times = format_times([status, entries.first].map(&:time))
          glucose_values = format_glucose_values(status, entries)
          iob = format_iob(loop.iob)
          cob = format_cob(loop.cob)
          puts "#{local_date} #{times} #{glucose_values} #{iob} #{cob}"
        end

        def format_date_time(time)
          time.localtime.strftime('%F %T')
        end

        def format_times(times)
          times.map { it.localtime.strftime('%T') }.join(' ')
        end

        def format_glucose_values(status, entries)
          entries.map { status.format(it.glucose) }.join(' ')
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
end
