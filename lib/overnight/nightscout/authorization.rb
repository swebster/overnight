# frozen_string_literal: true

require 'jwt'
require 'overnight/nightscout/client'
require 'overnight/nightscout/config'
require 'overnight/nightscout/contracts/authorization'

module Overnight
  class Nightscout
    # generates a temporary bearer JWT for authentication of subsequent requests
    class Authorization
      attr_reader :token, :subject, :permissions, :issued, :expires

      def self.request
        authorization = File.join('authorization', 'request', Nightscout::USER)
        Client.request(authorization, 'v2')
      end

      def self.parse(response)
        new(**Client.parse_hash(response, Contract.new).to_h)
      end

      def initialize(token:, sub:, permissionGroups:, iat:, exp:)
        @token = JWT::EncodedToken.new(token)
        @subject = sub
        @permissions = permissionGroups
        @issued = iat
        @expires = exp
      end

      def expired_after?(seconds:)
        @expires < Time.now + seconds
      end
    end
  end
end
