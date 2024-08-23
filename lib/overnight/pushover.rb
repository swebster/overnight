# frozen_string_literal: true

require 'overnight/pushover/config'
require 'typhoeus'

module Overnight
  # provides a wrapper around the Pushover API
  module Pushover
    def self.post(message)
      url = 'https://api.pushover.net/1/messages.json'
      params = { token: APP_TOKEN, user: USER_KEY, title: 'Test', message: }
      request = Typhoeus::Request.new(url, method: :post, params:)
      response = request.run
      puts "HTTP response code: #{response.code}"
      puts "HTTP response body: #{response.body}"
    end
  end
end
