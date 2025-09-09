# frozen_string_literal: true

require 'dotenv'
require 'overnight/error'

Dotenv.load('.env.local', '.env.secrets')

module Overnight
  # provides methods to fetch secrets and other values from the environment
  module Env
    def self.require_keys(secrets: [], keys: [])
      missing_secrets = secrets.map { "#{it}_FILE" } - ENV.keys
      Dotenv.require_keys(keys + missing_secrets.map { it[0, it.length - 5] })
    end

    def self.load_secret(key)
      secret_key = "#{key}_FILE"
      raise Error, "#{secret_key} is not defined" unless ENV.key?(secret_key)

      begin
        File.read(ENV[secret_key])
      rescue StandardError
        raise Error, "Unable to read #{secret_key}: #{ENV[secret_key]}"
      end
    end

    def self.fetch_unsigned(key)
      ENV[key].tap { validate_unsigned(key, it) }.to_i
    end

    def self.fetch_hour(key)
      fetch_unsigned(key).tap { validate_hour(key, it) }
    end

    def self.validate_unsigned(key, value)
      raise Error, "Non-unsigned value: #{key}" unless /\A\d+\Z/.match?(value)
    end

    def self.validate_hour(key, hour)
      raise Error, "Not a valid hour: #{key}" unless (0..23).include?(hour)
    end
  end
end
