# frozen_string_literal: true

require 'overnight/nightscout/client'
require 'overnight/nightscout/contracts/treatment'

module Overnight
  class Nightscout
    # anything that is likely to affect blood glucose, e.g. insulin, food, etc.
    module Treatment
      TemporaryOverride = Data.define(
        :timestamp, :correctionRange, :insulinNeedsScaleFactor, :reason
      )

      TempBasal = Data.define(:timestamp, :rate)

      CarbCorrection = Data.define(:timestamp, :absorptionTime, :carbs)

      CorrectionBolus = Data.define(:timestamp, :insulin)

      SuspendPump = Data.define(:timestamp)

      def self.request(token:, count: 12)
        Client.request('treatments', token:, params: { count: })
      end

      def self.parse(response)
        Client.parse_array(response, Contract.new).map { create(it) }
      end

      def self.create(result)
        event_type = result.context[:eventType]
        type = Class.const_get(qualified_name(event_type))
        type.new(**result.to_h)
      end

      def self.qualified_name(event_type)
        "#{name}::#{event_type.gsub(/\s+/, '')}"
      end

      # validates Nightscout API responses to treatment requests
      class Contract
        def initialize
          @event_type = EventTypeContract.new
          @subcontracts = Treatment::EVENT_TYPES.map do |event_type|
            class_name = Treatment.qualified_name(event_type).concat('Contract')
            [event_type, Class.const_get(class_name).new]
          end.to_h
        end

        def call(input, context = Dry::Core::Constants::EMPTY_HASH)
          result = @event_type.call(input, context)
          return result if result.failure?

          context = result.to_h.update(context)
          @subcontracts[result[:eventType]].call(input, context)
        end
      end
    end
  end
end
