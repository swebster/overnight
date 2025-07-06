# frozen_string_literal: true

module Overnight
  class Nightscout
    # describes the situation in which expected data has not been received
    class NoData
      def initialize(minutes)
        @minutes = minutes
      end

      def priority = 0

      def to_s
        "No data for the last #{@minutes} minutes"
      end
    end
  end
end
