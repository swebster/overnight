# frozen_string_literal: true

require 'dry-validation'

module Types # rubocop:disable Style/Documentation
  Dry.Types()

  UnixTime = Dry.Types.Constructor(Time) do |secs|
    Time.at(secs)
  end
end

module Overnight
  module Nightscout
    class Authorization
      # validates Nightscout API responses to authorization requests
      class Contract < Dry::Validation::Contract
        json do
          required(:token).value(:string)
          required(:sub).value(:string)
          required(:permissionGroups).value(:array, min_size?: 1).each do
            array(:str?)
          end
          required(:iat).filled(Types::UnixTime)
          required(:exp).filled(Types::UnixTime)
        end

        rule(:exp, :iat) do
          key.failure('must be after iat') if values[:exp] < values[:iat]
        end
      end
    end
  end
end
