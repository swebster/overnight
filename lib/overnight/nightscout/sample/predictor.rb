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
      # and the predicted duration that glucose will remain in that range
      class EntryRange
        VALID_RANGES = %i[urgent_low low normal high urgent_high].freeze

        extend Forwardable
        def_delegators :@entry, :time, :glucose
        attr_reader :range, :duration

        def initialize(entry, range, duration)
          raise Error, 'Invalid glucose range' unless VALID_RANGES.include?(range)

          @entry = entry
          @range = range
          @duration = duration
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
          cutoff = Time.now + 2 * 60 * 60 # two hours from now
          transitions = enumerate_transitions.take_while { it.last.time < cutoff }
          last_transition = transitions.pop
          transitions.each { print_transition(it, true) }
          print_transition(last_transition, false) unless last_transition.nil?
        end

        private

        def enumerate_transitions
          Enumerator.new do |y|
            y << @latest
            @predicted.each { y << it }
          end.each_cons(2)
        end

        def print_transition(transition, with_duration)
          a, b = *transition
          string = "#{Printer.format_date_time(b.time)} #{a.range} -> #{b.range}"
          string << " for #{(b.duration / 60).round} minutes" if with_duration
          puts string
        end
      end
    end
  end
end
