# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/contracts/treatment'

module Overnight
  class Nightscout
    # anything that is likely to affect blood glucose, e.g. insulin, food, etc.
    class Treatment
      attr_reader :timestamp

      def self.request(token:)
        Client.request('treatments', token:)
      end

      def self.parse(response)
        Client.parse_array(response, Contract.new).map do |treatment|
          new(**treatment.slice(:timestamp))
        end
      end

      def initialize(timestamp:)
        @timestamp = timestamp
      end
    end
  end
end
