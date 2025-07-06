# frozen_string_literal: true

require 'overnight/http_client'
require 'overnight/pushover/config'

module Overnight
  # provides a wrapper around the Pushover API
  module Pushover
    extend HTTPClient

    def self.post(message, title:, priority: 0)
      url = 'https://api.pushover.net/1/messages.json'
      params = { token: APP_TOKEN, user: USER_KEY, title:, message:, priority: }
      # retry urgent messages every 60 seconds for 30 minutes until acknowledged
      params.update({ retry: 60, expire: 1800 }) if priority == 2
      request = Typhoeus::Request.new(url, method: :post, params:)
      request.run.tap { |response| validate_http(response) }.body
    end
  end
end
