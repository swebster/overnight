# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/config'

module Overnight
  module Nightscout
    # generates a temporary bearer JWT for authentication of subsequent requests
    class Authorization
      def self.request
        authorization = File.join('authorization', 'request', Nightscout::USER)
        Client.request(authorization, 'v2')
      end
    end
  end
end
