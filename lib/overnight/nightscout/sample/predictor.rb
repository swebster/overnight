# frozen_string_literal: true

require 'forwardable'
require 'overnight/nightscout/entry'
require 'overnight/nightscout/error'
require 'overnight/nightscout/sample/printer'
require 'overnight/nightscout/treatment'

module Overnight
  class Nightscout
    class Sample
      # extends Entry with a range that corresponds to its glucose value
      class EntryRange
        VALID_RANGES = %i[urgent_low low normal high urgent_high].freeze

        extend Forwardable
        def_delegators :@entry, :time, :glucose
        attr_reader :range

        def initialize(entry, range)
          raise Error, 'Invalid glucose range' unless VALID_RANGES.include?(range)

          @entry = entry
          @range = range
        end
      end

      # generates alerts about predicted glycemic events
      class Predictor
        def initialize(latest_predicted, treatments)
          raise Error, 'No glucose entries provided' if latest_predicted.empty?

          @latest = latest_predicted.shift
          @predicted = latest_predicted
          @treatments = treatments
        end

        def print_transitions
          each_transition do |(a, b)|
            puts "#{Printer.format_date_time(b.time)} #{a.range} -> #{b.range}"
          end
        end

        private

        def each_transition(&block)
          Enumerator.new do |y|
            y << @latest
            @predicted.each { y << it }
          end.each_cons(2).each(&block)
        end
      end
    end
  end
end
