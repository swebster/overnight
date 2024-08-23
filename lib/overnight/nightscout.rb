# frozen_string_literal: true

require 'overnight/nightscout/authorization'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'

module Overnight
  # provides a wrapper around the Nightscout API
  module Nightscout
    def self.get(limit: 12)
      hydra = Typhoeus::Hydra.new
      request_entry = Entry.request(limit:)
      request_status = DeviceStatus.request

      hydra.queue(request_entry)
      hydra.queue(request_status)
      hydra.run

      entries = Entry.parse(request_entry.response)
      loop = DeviceStatus.parse(request_status.response).first
      { entries:, loop: }
    end
  end
end
