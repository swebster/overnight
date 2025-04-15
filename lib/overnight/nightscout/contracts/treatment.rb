# frozen_string_literal: true

require 'dry-validation'

module Overnight
  class Nightscout
    class Treatment
      # validates Nightscout API responses to treatment requests
      class Contract < Dry::Validation::Contract
        json do
          required(:timestamp).filled(:time)
          required(:eventType).filled(:string)
        end
      end
    end
  end
end
