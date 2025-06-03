# frozen_string_literal: true

require 'overnight/nightscout/authorization'
require 'overnight/nightscout/sample'
require 'overnight/utils'

module Overnight
  # provides a wrapper around the Nightscout API
  class Nightscout
    def initialize(entry_params: {}, device_params: {}, treatment_params: {})
      @entry_params = entry_params.compact
      @device_params = device_params.compact
      @treatment_params = treatment_params.compact
    end

    def get(validate: true)
      request_authorization if token_expiring?
      create_requests
      request_data
      parse_responses(validate)
    end

    def abort
      @hydra&.abort
    end

    private

    def token_expiring?
      @auth.nil? || @auth.expired_after?(seconds: 300)
    end

    def request_authorization
      response = Authorization.request.run
      Client.validate_http(response)
      @auth = Authorization.parse(response.body)
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
      @requests.each_value { |request| Client.validate_http(request.response) }
    end

    def parse_responses(validate)
      @requests.map do |type, request|
        response_body = request.response.body
        value = validate ? type.parse(response_body) : JSON.parse(response_body)
        [Overnight::Utils.snake_sym(type.name.split('::').last), value]
      end.to_h
    end
  end
end
