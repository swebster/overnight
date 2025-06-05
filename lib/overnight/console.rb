# frozen_string_literal: true

require 'overnight/nightscout'
require 'overnight/pushover'
require 'rufus-scheduler'

module Overnight
  # controls periodic sampling of Nightscout data and output to the terminal
  class Console
    def initialize(silent: false)
      @nightscout = Nightscout.new
      @scheduler = Rufus::Scheduler.new
      @silent = silent
    end

    def sample_every(interval)
      Nightscout::Sample.print_column_headers unless @silent
      @scheduler.every(interval, first: :now) do |job|
        sample = fetch_sample
        sample.print_row unless @silent
        report_problems(sample)
        job.next_time = sample.next_time if sample.mistimed?
      rescue Overnight::Error => e
        warn e.message
      end
    end

    def start_sampling
      @scheduler.join
    end

    def stop_sampling
      @scheduler.shutdown(:wait)
      @nightscout.abort
    end

    private

    def fetch_sample
      time = Time.now
      keys = %i[entry device_status status treatment]
      values = @nightscout.get.fetch_values(*keys)
      Nightscout::Sample.new(time, *values)
    end

    def report_problems(sample)
      if sample.missed_samples.zero?
        warn_listeners(sample.problems, messages_per_hour: 2)
      # Dexcom warns every 30 minutes, so warn after 15 and every 30 after that
      elsif ((sample.missed_samples + 3) % 6).zero?
        message = "No data for the last #{sample.delay / 60} minutes"
        warn_listeners([message], messages_per_hour: 4)
      end
    end

    def warn_listeners(problems, messages_per_hour:)
      return if problems.empty?

      problems.each { warn "Warning: #{it}" } # always log warnings to stderr
      message = problems.map { Nightscout::Printer.format_plain(it) }.join("\n")
      post_warning(message, messages_per_hour)
    end

    def post_warning(message, messages_per_hour)
      interval = @last_posted.nil? ? nil : (Time.now - @last_posted).floor / 60
      min_interval = (60 / messages_per_hour.clamp(2..6)) - 1
      return if !interval.nil? && interval < min_interval

      Pushover.post(message, title: 'Warning')
      @last_posted = Time.now
    end
  end
end
