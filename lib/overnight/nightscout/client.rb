# frozen_string_literal: true

require 'json'
require 'typhoeus'
require 'overnight/nightscout/error'
require 'overnight/nightscout/url'

module Overnight
  class Nightscout
    # generic wrapper for all Nightscout API requests and responses
    module Client
      def self.request(path_segment, api_version = 'v1', token: nil, **options)
        url = Url.join(path_segment, api_version)
        options[:headers] = { Accept: 'application/json' }.merge(options[:headers] || {})
        options[:headers].merge!({ Authorization: "Bearer #{token.jwt}" }) if token

        Typhoeus::Request.new(url, options)
      end

      def self.validate_http(response)
        if response.nil?
          # possible if the host went to sleep before the server replied
          raise Error, 'No HTTP response received'
        elsif response.success?
          # valid; response.body should be in the expected format
        elsif response.timed_out?
          raise Error, 'HTTP request timed out'
        elsif response.code.zero?
          # could not get an HTTP response, something is wrong
          raise Error, response.return_message
        else
          # received a non-successful HTTP response
          raise Error, "HTTP request failed: #{response.code}"
        end
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
