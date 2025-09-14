# frozen_string_literal: true

require 'overnight/error'

module Overnight
  class Pushover
    # provides methods to validate params before sending requests to Pushover
    module Validator
      VALID_KEY = /[A-Za-z0-9]{30}/

      def self.validate_key(key, type:)
        raise Error, "Invalid #{type} key: #{key}" unless VALID_KEY.match?(key)
      end
    end
  end
end
