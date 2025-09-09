# frozen_string_literal: true

require 'overnight/env'

Overnight::Env.require_keys(keys: %w[OVERNIGHT_PERIOD_BEGIN OVERNIGHT_PERIOD_END])

module Overnight
  PERIOD_BEGIN = Env.fetch_hour('OVERNIGHT_PERIOD_BEGIN')
  PERIOD_END   = Env.fetch_hour('OVERNIGHT_PERIOD_END')
end
