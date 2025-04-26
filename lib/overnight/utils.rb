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
  end
end
