# frozen_string_literal: true

require 'typhoeus'
require 'overnight/error'

module Overnight
  # provides a method to validate typhoeus responses
  module HTTPClient
    def validate_http(response)
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
  end
end
