# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/entry/contract'

module Overnight
  class Nightscout
    # blood glucose readings, either from a CGM (type: "sgv") or manual (type: "mbg")
    class Entry
      attr_reader :time, :glucose

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

      def <=>(other)
        @glucose <=> other.glucose
      end
    end
  end
end
