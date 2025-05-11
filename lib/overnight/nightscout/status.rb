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

      def self.parse(response_body)
        new(**Client.parse_hash(response_body, Contract.new).to_h)
      end

      def initialize(status:, serverTime:, settings:)
        @status = status
        @time = serverTime
        @glucose_ranges = GlucoseRanges.new(settings[:thresholds])
      end

      def categorize(glucose)
        @glucose_ranges.find(glucose).name
      end
    end
  end
end
