# frozen_string_literal: true

require 'overnight/nightscout/sample/entry_range'
require 'overnight/nightscout/treatment'

module Overnight
  class Nightscout
    class Sample
      # generates alerts about predicted glycemic events
      class Predictor
        def initialize(entry_ranges, treatments)
          raise Error, 'No glucose entries provided' if entry_ranges.empty?

          @entry_ranges = entry_ranges
          @treatments = treatments
        end
      end
    end
  end
end
