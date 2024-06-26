# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/device_status/contract'
require 'overnight/nightscout/entry'

module Overnight
  module Nightscout
    # the status of the devices uploading data to Nightscout, such as Loop or OpenAPS
    class DeviceStatus
      attr_reader :entries

      def self.request(limit: 1)
        Client.request('devicestatus', params: { count: limit })
      end

      def self.parse(response)
        Client.parse_array(response, Contract.new).map { new(**_1) }
      end

      def initialize(loop:)
        predicted = loop[:predicted]
        start_date = predicted[:startDate]

        @entries = predicted[:values].each_with_index.map do |glucose, index|
          time = start_date + (300 * index)
          Entry.new(dateString: time, type: 'sgv', sgv: glucose)
        end.drop(1) # the first 'prediction' is actually the most recent reading
      end
    end
  end
end
