# frozen_string_literal: true

require 'overnight/env'

Overnight::Env.require_keys(secrets: %w[PUSHOVER_APP_TOKEN PUSHOVER_USER_KEY])

module Overnight
  class Pushover
    APP_TOKEN = ENV['PUSHOVER_APP_TOKEN'] || Env.load_secret('PUSHOVER_APP_TOKEN')
    USER_KEY  = ENV['PUSHOVER_USER_KEY']  || Env.load_secret('PUSHOVER_USER_KEY')
  end
end
