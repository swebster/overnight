# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/status/contract'
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

      def format(glucose)
        colour = @glucose_ranges.find(glucose).colour
        colour.call(Kernel.format('%4.1f', glucose / 18.0))
      end
    end
  end
end
