# frozen_string_literal: true

require 'dry-validation'

module Overnight
  class Nightscout
    class DeviceStatus
      # validates Nightscout API responses to devicestatus requests
      class Contract < Dry::Validation::Contract
        json do
          required(:loop).hash(:filled?) do
            required(:timestamp).filled(:time)
            required(:predicted).hash(:filled?) do
              required(:startDate).filled(:time)
              required(:values).array(:filled?) { int? | float? }
            end
            required(:cob).hash(:filled?) do
              required(:timestamp).filled(:time)
              required(:cob).filled { (int? | float?) & gteq?(0) }
            end
            required(:iob).hash(:filled?) do
              required(:timestamp).filled(:time)
              required(:iob).filled { int? | float? }
            end
          end
        end
      end
    end
  end
end
