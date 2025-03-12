# frozen_string_literal: true

require 'overnight/nightscout/authorization'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/device_status'
require 'overnight/nightscout/status'

module Overnight
  # provides a wrapper around the Nightscout API
  class Nightscout
    def initialize(entry_params: {}, device_params: {})
      @hydra = Typhoeus::Hydra.new
      @entry_params = entry_params.compact
      @device_params = device_params.compact
    end

    def get
      if token_expiring?
        request_authorization
        create_requests
      end
      request_data
      parse_responses
    end

    private

    def token_expiring?
      @auth.nil? || @auth.expired_after?(seconds: 300)
    end

    def request_authorization
      request_auth = Authorization.request
      @auth = Authorization.parse(request_auth.run)
    end

    def create_requests
      @requests = {}
      token = @auth.token
      @requests[Entry] = Entry.request(token:, **@entry_params)
      @requests[DeviceStatus] = DeviceStatus.request(token:, **@device_params)
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
