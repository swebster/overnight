# frozen_string_literal: true

require 'forwardable'

module Overnight
  class Nightscout
    class Status
      Category = Data.define(:range, :name) do
        extend Forwardable
        def_delegators :range, :include?
      end

      # categorises blood glucose values in accordance with the given thresholds
      class GlucoseRanges
        def initialize(thresholds)
          @categories = map_categories(create_ranges(thresholds))
        end

        def find(glucose)
          @categories.find { it.include?(glucose.round) }
        end

        private

        def create_ranges(thresholds)
          # the first two values are upper bounds, the second two lower bounds
          ub = thresholds.fetch_values(:bgLow, :bgTargetBottom)
          lb = thresholds.fetch_values(:bgTargetTop, :bgHigh)

          # create complementary sets of upper and lower bounds for each
          upper_bounds = ub + lb.map(&:pred)
          lower_bounds = ub.map(&:succ) + lb

          bounds = [nil, *upper_bounds.zip(lower_bounds).flatten, nil]
          bounds.each_slice(2).map { |min_max| Range.new(*min_max) }
        end

        def map_categories(ranges)
          urgent_low  = Category.new(ranges[0], :urgent_low)
          low         = Category.new(ranges[1], :low)
          normal      = Category.new(ranges[2], :normal)
          high        = Category.new(ranges[3], :high)
          urgent_high = Category.new(ranges[4], :urgent_high)

          # sort these in descending frequency order, i.e. common to rare
          [normal, high, low, urgent_high, urgent_low]
        end
      end
    end
  end
end
