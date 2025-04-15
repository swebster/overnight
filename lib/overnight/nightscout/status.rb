# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/contracts/status'
require 'overnight/nightscout/status/glucose_ranges'

module Overnight
  class Nightscout
    # the status of Nightscout itself, including configured alarm thresholds
    class Status
      attr_reader :status, :time

      def self.request(token:)
        Client.request('status', token:)
      end

      def self.parse(response)
        new(**Client.parse_hash(response, Contract.new))
      end

      def initialize(status:, serverTime:, settings:)
        @status = status
        @time = serverTime
        @glucose_ranges = GlucoseRanges.new(settings[:thresholds])
      end

      def categorize(glucose)
        find(glucose).name
      end

      def format(glucose)
        find(glucose).colour.call(Kernel.format('%4.1f', glucose / 18.0))
      end

      private

      def find(glucose)
        @glucose_ranges.find(glucose)
      end
    end
  end
end
