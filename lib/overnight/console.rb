# frozen_string_literal: true

require 'overnight/config'
require 'overnight/nightscout'
require 'overnight/nightscout/no_data'
require 'overnight/pushover'
require 'rufus-scheduler'

module Overnight
  # controls periodic sampling of Nightscout data and output to the terminal
  class Console
    def initialize(push_notifications:, log_samples:)
      @nightscout = Nightscout.new
      @scheduler = Rufus::Scheduler.new
      @mutex = Mutex.new # for synchronizing output from concurrent tasks
      @push_notifications = push_notifications
      @log_samples = log_samples
    end

    def sample_every(interval)
      Nightscout::Sample.print_column_headers if @log_samples
      schedule_every(interval, first: :now) do |job|
        sample = fetch_sample
        print_row(sample) if @log_samples
        report_problems(sample)
        job.next_time = sample.next_time if sample.mistimed?
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

    def print_row(sample)
      formatted_row = sample.format_row
      @mutex.synchronize { puts formatted_row }
    end

    def report_problems(sample)
      if sample.missed_samples.zero?
        problem = sample.problem
        warn_listeners(problem, messages_per_hour: 2) unless problem.nil?
      # Dexcom warns every 30 minutes, so warn after 15 and every 30 after that
      elsif ((sample.missed_samples + 3) % 6).zero?
        problem = Nightscout::NoData.new(sample.delay / 60)
        warn_listeners(problem, messages_per_hour: 4)
      end
    end

    def warn_listeners(problem, messages_per_hour:)
      formatted_message = problem.to_s
      # always log warnings to stderr
      @mutex.synchronize { warn "Warning: #{formatted_message}" }
      message = Nightscout::Printer.format_plain(formatted_message)
      priority = overnight_boost(problem.priority, Time.now)
      post_warning(message, priority, messages_per_hour) if @push_notifications
    end

    def overnight_boost(priority, time)
      overnight_hours = Utils.hours_in_range(PERIOD_BEGIN, PERIOD_END)
      overnight_hours.include?(time.hour) ? (priority + 1).clamp(..2) : priority
    end

    def post_warning(message, priority, messages_per_hour)
      interval = @last_posted.nil? ? nil : (Time.now - @last_posted).floor / 60
      min_interval = (60 / messages_per_hour.clamp(2..6)) - 1
      return if !interval.nil? && interval < min_interval

      receipt = Pushover.post(message, priority:)
      @last_posted = Time.now
      wait_for_ack(receipt) if receipt && Pushover.using_group_key?
    end

    def wait_for_ack(receipt)
      schedule_every('1m', first: '30s', times: 30) do |job|
        if (status = Pushover.check_status(receipt))
          job.unschedule
          Pushover.publish_response(status)
        end
      end
    end

    def schedule_every(*, **, &block)
      @scheduler.every(*, **) do |job|
        block.call(job)
      rescue Overnight::Error => e
        @mutex.synchronize { warn e.message }
      end
    end
  end
end
