# frozen_string_literal: true

require 'dotenv/load'
require 'overnight/error'

module Overnight
  # provides methods to fetch container secrets from the environment
  module Env
    def self.require_keys(secrets:, keys: [])
      missing_secrets = secrets.map { "#{it}_FILE" } - ENV.keys
      Dotenv.require_keys(keys + missing_secrets.map { it[0, it.length - 5] })
    end

    def self.load_secret(key:)
      secret_key = "#{key}_FILE"
      raise Error, "#{secret_key} is not defined" unless ENV.key?(secret_key)

      begin
        File.read(ENV[secret_key])
      rescue StandardError
        raise Error, "Unable to read #{secret_key}: #{ENV[secret_key]}"
      end
    end
  end
end
