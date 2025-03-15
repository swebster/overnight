# frozen_string_literal: true

require 'dry-validation'

module Overnight
  class Nightscout
    class Status
      # validates Nightscout API responses to status requests
      class Contract < Dry::Validation::Contract
        json do
          required(:status).filled(:string)
          required(:serverTime).filled(:time)
          required(:settings).hash(:filled?) do
            required(:thresholds).hash(:filled?) do
              required(:bgHigh).filled(:integer, gt?: 0)
              required(:bgTargetTop).filled(:integer, gt?: 0)
              required(:bgTargetBottom).filled(:integer, gt?: 0)
              required(:bgLow).filled(:integer, gt?: 0)
            end
          end
        end
      end
    end
  end
end
