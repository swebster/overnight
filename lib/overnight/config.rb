# frozen_string_literal: true

require 'overnight/env'

Overnight::Env.require_keys(keys: %w[OVERNIGHT_PERIOD_BEGIN OVERNIGHT_PERIOD_END])

module Overnight
  HIGH_OVERRIDE = Env.fetch_string('OVERNIGHT_HIGH_OVERRIDE')
  PERIOD_BEGIN  = Env.fetch_hour('OVERNIGHT_PERIOD_BEGIN')
  PERIOD_END    = Env.fetch_hour('OVERNIGHT_PERIOD_END')
end
