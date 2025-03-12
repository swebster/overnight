# frozen_string_literal: true

require 'dotenv/load'

Dotenv.require_keys('NIGHTSCOUT_HOST', 'NIGHTSCOUT_USER')

module Overnight
  class Nightscout
    HOST = ENV['NIGHTSCOUT_HOST']
    PORT = ENV['NIGHTSCOUT_PORT']
    USER = ENV['NIGHTSCOUT_USER']
  end
end
