# frozen_string_literal: true

require 'dry-validation'

module Types # rubocop:disable Style/Documentation
  Dry.Types()

  UnixTime = Dry.Types.Constructor(Time) do |secs|
    Time.at(secs)
  end
end

module Overnight
  class Nightscout
    class Authorization
      # validates Nightscout API responses to authorization requests
      class Contract < Dry::Validation::Contract
        json do
          required(:token).filled(:string)
          required(:sub).filled(:string)
          required(:permissionGroups).filled(:array).each do
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
