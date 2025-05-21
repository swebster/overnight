# frozen_string_literal: true

require 'overnight/http_client'
require 'overnight/pushover/config'

module Overnight
  # provides a wrapper around the Pushover API
  module Pushover
    extend HTTPClient

    def self.post(message)
      url = 'https://api.pushover.net/1/messages.json'
      params = { token: APP_TOKEN, user: USER_KEY, title: 'Test', message: }
      request = Typhoeus::Request.new(url, method: :post, params:)
      request.run.tap { |response| validate_http(response) }.body
    end
  end
end
