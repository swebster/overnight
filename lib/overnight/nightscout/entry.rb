# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/entry/contract'

module Overnight
  module Nightscout
    # blood glucose readings, either from a CGM (type: "sgv") or manual (type: "mbg")
    class Entry
      attr_reader :time

      def self.request(token:, count: 12)
        Client.request('entries', token:, params: { count: })
      end

      def self.parse(response)
        Client.parse_array(response, Contract.new).map { new(**_1) }
      end

      def initialize(dateString:, type:, mbg: nil, sgv: nil)
        @time = dateString
        @glucose = type == 'sgv' ? sgv : mbg
      end

      def glucose
        @glucose / 18.0
      end

      def to_s
        format('%s: %4.1f', time.localtime, glucose)
      end
    end
  end
end
