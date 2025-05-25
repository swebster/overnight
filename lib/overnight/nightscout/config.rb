# frozen_string_literal: true

require 'overnight/env'

Overnight::Env.require_keys(keys: ['NIGHTSCOUT_HOST'], secrets: ['NIGHTSCOUT_USER'])

module Overnight
  class Nightscout
    HOST = ENV['NIGHTSCOUT_HOST']
    PORT = ENV['NIGHTSCOUT_PORT']
    USER = ENV['NIGHTSCOUT_USER'] || Env.load_secret('NIGHTSCOUT_USER')
  end
end
