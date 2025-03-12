# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/status/contract'

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
        @thresholds = settings[:thresholds]
      end

      def thresholds
        @thresholds.transform_values { _1 / 18.0 }
      end

      def to_s
        s = format('%s: Status: %s, ', time.localtime, status)
        s << thresholds.map { |k, v| format('%s: %.1f', k, v) }.join(', ')
      end
    end
  end
end
