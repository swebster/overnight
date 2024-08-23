# frozen_string_literal: true

require 'dotenv/load'

Dotenv.require_keys('PUSHOVER_APP_TOKEN', 'PUSHOVER_USER_KEY')

module Overnight
  module Pushover
    APP_TOKEN = ENV['PUSHOVER_APP_TOKEN']
    USER_KEY  = ENV['PUSHOVER_USER_KEY']
  end
end
