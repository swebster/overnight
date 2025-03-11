# frozen_string_literal: true

require 'dry-validation'

module Overnight
  module Nightscout
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
          end
        end
      end
    end
  end
end
