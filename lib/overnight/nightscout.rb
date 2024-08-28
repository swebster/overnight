# frozen_string_literal: true

require 'overnight/nightscout/authorization'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/status'

module Overnight
  # provides a wrapper around the Nightscout API
  module Nightscout
    def self.get(entry_params: {}, device_params: {})
      hydra = Typhoeus::Hydra.new
      request_entry = Entry.request(**entry_params.compact)
      request_device = DeviceStatus.request(**device_params.compact)
      request_status = Status.request

      hydra.queue(request_entry)
      hydra.queue(request_device)
      hydra.queue(request_status)
      hydra.run

      entries = Entry.parse(request_entry.response)
      devices = DeviceStatus.parse(request_device.response)
      status = Status.parse(request_status.response)
      { entries:, devices:, status: }
    end
  end
end
