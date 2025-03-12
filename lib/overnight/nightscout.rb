# frozen_string_literal: true

require 'overnight/nightscout/authorization'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/status'

module Overnight
  # provides a wrapper around the Nightscout API
  class Nightscout
    def get(entry_params: {}, device_params: {})
      request_authorization if token_expiring?
      create_requests(entry_params:, device_params:)
      request_data
      parse_responses
    end

    def initialize
      @hydra = Typhoeus::Hydra.new
    end

    private

    def token_expiring?
      @auth.nil? || @auth.expired_after?(seconds: 300)
    end

    def request_authorization
      request_auth = Authorization.request
      @auth = Authorization.parse(request_auth.run)
    end

    def create_requests(entry_params: {}, device_params: {})
      @requests = {}
      token = @auth.token
      @requests[Entry] = Entry.request(token:, **entry_params.compact)
      @requests[DeviceStatus] = DeviceStatus.request(token:, **device_params.compact)
      @requests[Status] = Status.request(token:)
    end

    def request_data
      @requests.each_value { |request| @hydra.queue(request) }
      @hydra.run
    end

    def parse_responses
      @requests.map do |type, request|
        [snake_sym(type.name.split('::').last), type.parse(request.response)]
      end.to_h
    end

    def snake_sym(subtype)
      subtype.gsub(/(?<=[a-z])(?=[A-Z])/, '_').downcase.to_sym
    end
  end
end
