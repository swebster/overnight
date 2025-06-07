# frozen_string_literal: true

require 'optparse'

module Overnight
  # a simple command-line options parser
  module Options
    def self.create_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
        opts.on('-p', '--[no-]push-notifications', 'Send messages via Pushover')
        opts.on('-l', '--[no-]log', 'Log samples from Nightscout')
      end
    end

    def self.rename_keys(options)
      old_keys = %w[push-notifications log].map(&:to_sym)
      new_keys = %i[push_notifications log_samples]
      replacements = old_keys.zip(new_keys).to_h
      options.transform_keys { replacements[it] }
    end

    def self.parse
      options = {}
      create_parser.parse!(into: options)
      default_options = { push_notifications: false, log_samples: false }
      default_options.merge(rename_keys(options))
    end
  end
end
