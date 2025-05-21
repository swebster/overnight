# frozen_string_literal: true

require 'json'
require 'overnight/http_client'
require 'overnight/nightscout/url'

module Overnight
  class Nightscout
    # generic wrapper for all Nightscout API requests and responses
    module Client
      extend HTTPClient

      def self.request(path_segment, api_version = 'v1', token: nil, **options)
        url = Url.join(path_segment, api_version)
        options[:headers] = { Accept: 'application/json' }.merge(options[:headers] || {})
        options[:headers].merge!({ Authorization: "Bearer #{token.jwt}" }) if token

        Typhoeus::Request.new(url, options)
      end

      def self.validate_body(element, contract)
        contract.call(element).tap do |result|
          raise Error, "#{contract.class}: errors=#{result.errors.to_h}" if result.failure?
        end
      end

      def self.parse_array(response_body, contract)
        JSON.parse(response_body, symbolize_names: true).map do |element|
          validate_body(element, contract)
        end
      end

      def self.parse_hash(response_body, contract)
        validate_body(JSON.parse(response_body, symbolize_names: true), contract)
      end
    end
  end
end
