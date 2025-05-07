# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/contracts/entry'

module Overnight
  class Nightscout
    # blood glucose readings, either from a CGM (type: "sgv") or manual (type: "mbg")
    class Entry
      include Comparable

      attr_reader :time, :glucose

      def self.request(token:, count: 12)
        Client.request('entries', token:, params: { count: })
      end

      def self.parse(response_body)
        Client.parse_array(response_body, Contract.new).map { new(**it.to_h) }
      end

      def initialize(dateString:, type:, mbg: nil, sgv: nil)
        @time = dateString
        @glucose = type == 'sgv' ? sgv : mbg
      end

      def <=>(other)
        return nil unless other.is_a?(self.class)

        # order by glucose, then take the earliest entry with that glucose value
        2 * (@glucose <=> other.glucose) + (@time <=> other.time)
      end
    end
  end
end
