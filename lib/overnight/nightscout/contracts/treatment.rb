# frozen_string_literal: true

require 'dry-validation'

module Overnight
  class Nightscout
    class Treatment
      TimedEventSchema = Dry::Schema.JSON do
        required(:timestamp).filled(:time)
      end

      # rubocop:disable Style/Documentation
      class EventTypeContract < Dry::Validation::Contract
        json do
          required(:eventType).filled(included_in?:
            ['Temporary Override',
             'Temp Basal',
             'Carb Correction',
             'Correction Bolus',
             'Suspend Pump'])
        end
      end

      class TemporaryOverrideContract < Dry::Validation::Contract
        json(TimedEventSchema) do
          required(:correctionRange).value(:array, size?: 2).each { float? & gteq?(0) }
          required(:insulinNeedsScaleFactor).filled { float? & gteq?(0) }
          required(:reason).filled(:string)
        end
      end

      class TempBasalContract < Dry::Validation::Contract
        json(TimedEventSchema) do
          required(:rate).filled { (int? | float?) & gteq?(0) }
        end
      end

      class CarbCorrectionContract < Dry::Validation::Contract
        json(TimedEventSchema) do
          required(:absorptionTime).filled { int? & gteq?(0) }
          required(:carbs).filled { int? & gteq?(0) }
        end
      end

      class CorrectionBolusContract < Dry::Validation::Contract
        json(TimedEventSchema) do
          required(:insulin).filled { (int? | float?) & gteq?(0) }
        end
      end

      class SuspendPumpContract < Dry::Validation::Contract
        json(TimedEventSchema)
      end
      # rubocop:enable Style/Documentation

      # validates Nightscout API responses to treatment requests
      class Contract
        def initialize
          @event_type = EventTypeContract.new
          @subcontracts = {
            'Temporary Override' => TemporaryOverrideContract.new,
            'Temp Basal' => TempBasalContract.new,
            'Carb Correction' => CarbCorrectionContract.new,
            'Correction Bolus' => CorrectionBolusContract.new,
            'Suspend Pump' => SuspendPumpContract.new
          }
        end

        def call(input, context = Dry::Core::Constants::EMPTY_HASH)
          result = @event_type.call(input, context)
          return result if result.failure?

          @subcontracts[result[:eventType]].call(input, context.merge(result.to_h))
        end
      end
    end
  end
end
