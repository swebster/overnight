# frozen_string_literal: true

require 'dry-validation'

module Overnight
  class Nightscout
    class Entry
      # validates Nightscout API responses to entry requests
      class Contract < Dry::Validation::Contract
        register_macro(:entry_type) do
          if values[:type] == key_name.to_s
            key.failure("must be provided for an #{key_name.upcase} entry") unless key?
          elsif key?
            key.failure("must not be provided for a non-#{key_name.upcase} entry")
          end
        end

        json do
          required(:dateString).value(:time)
          required(:type).value(included_in?: %w[mbg sgv])
          optional(:mbg).value(:integer, gt?: 0)
          optional(:sgv).value(:integer, gt?: 0)
        end

        rule(:mbg).validate(:entry_type)
        rule(:sgv).validate(:entry_type)
      end
    end
  end
end
