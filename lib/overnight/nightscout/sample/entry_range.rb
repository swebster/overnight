# frozen_string_literal: true

require 'overnight/nightscout/error'
require 'overnight/nightscout/sample/printer'
require 'overnight/nightscout/sample/synchronizer'

module Overnight
  class Nightscout
    class Sample
      # extends Entry with a range that corresponds to its glucose value
      # and the predicted duration that glucose will remain in that range
      class EntryRange
        attr_reader :time, :glucose, :range, :duration

        VALID_RANGES = %i[urgent_low low normal high urgent_high].freeze

        def self.group_entries_by_range(entries, &to_range)
          groups = entries.slice_when { |a, b| to_range.call(a) != to_range.call(b) }
          groups.map { [to_range.call(it.first), it] }
        end

        def self.consolidate(entries, &to_range)
          group_entries_by_range(entries, &to_range).map do |range, group|
            duration = group.last.time - group.first.time + Synchronizer::LOOP_INTERVAL
            EntryRange.new(group.first.time, group.first.glucose, range, duration)
          end
        end

        def self.each_transition(entry_ranges, &block)
          transitions = entry_ranges.each_cons(2).to_a
          last_transition = transitions.pop
          transitions.each { block.call(it, true) }
          block.call(last_transition, false) unless last_transition.nil?
        end

        def self.print_transition(transition, with_duration)
          a, b = *transition
          string = "#{Printer.format_date_time(b.time)} #{a.range} -> #{b.range}"
          string << " for #{(b.duration / 60).round} minutes" if with_duration
          puts string
        end

        def initialize(time, glucose, range, duration)
          raise Error, 'Invalid glucose range' unless VALID_RANGES.include?(range)

          @time = time
          @glucose = glucose
          @range = range
          @duration = duration
        end
      end
    end
  end
end
