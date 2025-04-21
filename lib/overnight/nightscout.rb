# frozen_string_literal: true

require 'overnight/nightscout/authorization'
require 'overnight/nightscout/sample'

module Overnight
  # provides a wrapper around the Nightscout API
  class Nightscout
    def initialize(entry_params: {}, device_params: {}, treatment_params: {})
      @entry_params = entry_params.compact
      @device_params = device_params.compact
      @treatment_params = treatment_params.compact
    end

    def get
      request_authorization if token_expiring?
      create_requests
      request_data
      parse_responses
    end

    def abort
      @hydra&.abort
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
      @requests[Treatment] = Treatment.request(token:, **@treatment_params)
    end

    def request_data
      @hydra = Typhoeus::Hydra.new
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
