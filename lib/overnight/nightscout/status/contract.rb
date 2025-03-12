# frozen_string_literal: true

require 'dry-validation'

module Overnight
  class Nightscout
    class Status
      # validates Nightscout API responses to status requests
      class Contract < Dry::Validation::Contract
        json do
          required(:status).value(:string)
          required(:serverTime).value(:time)
          required(:settings).hash(:filled?) do
            required(:thresholds).hash(:filled?) do
              required(:bgHigh).value(:integer, gt?: 0)
              required(:bgTargetTop).value(:integer, gt?: 0)
              required(:bgTargetBottom).value(:integer, gt?: 0)
              required(:bgLow).value(:integer, gt?: 0)
            end
          end
        end
      end
    end
  end
end
