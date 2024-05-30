# frozen_string_literal: true

require 'dotenv/load'

Dotenv.require_keys('NIGHTSCOUT_HOST', 'NIGHTSCOUT_USER')

module Overnight
  module Nightscout
    HOST = ENV['NIGHTSCOUT_HOST']
    USER = ENV['NIGHTSCOUT_USER']
  end
end
