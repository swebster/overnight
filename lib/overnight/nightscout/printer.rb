# frozen_string_literal: true

require 'rainbow'

module Overnight
  class Nightscout
    # standardises formatting when printing various properties to $stdout
    module Printer
      RANGE_COLOURS = Hash.new { ->(s) { s } }.update({
         urgent_low: ->(s) { Rainbow(s).bg(:red) },
                low: ->(s) { Rainbow(s).red },
               high: ->(s) { Rainbow(s).yellow },
        urgent_high: ->(s) { Rainbow(s).black.bg(:yellow) }
      }).freeze

      module_function

      def format_plain(string)
        Rainbow.uncolor(string)
      end

      def format_warning(string)
        Rainbow(string).yellow
      end

      def format_error(string)
        Rainbow(string).red
      end

      def format_date_time(time)
        time.localtime.strftime('%F %T')
      end

      def format_time(time)
        time.localtime.strftime('%T')
      end

      def format_glucose(glucose, range, fixed_width: false)
        format_string = fixed_width ? '%4.1f' : '%.1f'
        RANGE_COLOURS[range].call(format(format_string, glucose / 18.0))
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
