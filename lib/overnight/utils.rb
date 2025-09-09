# frozen_string_literal: true

module Overnight
  # provides generic methods that extend Ruby core
  module Utils
    def self.snake_case(string)
      string.gsub(/(?<=[a-z])(?=[A-Z])/, '_').downcase
    end

    def self.snake_sym(string)
      snake_case(string).to_sym
    end

    # both parameters are assumed to be integers in the range (0..23)
    def self.hours_in_range(from, to)
      if from < to
        [*(from..(to - 1))]
      else # from >= to
        [*(0..(to - 1)), *(from..23)]
      end.to_set
    end
  end
end
