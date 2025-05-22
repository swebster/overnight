# frozen_string_literal: true

require 'optparse'

module Overnight
  # a simple command-line options parser
  module Options
    def self.parse
      {}.tap do |options|
        OptionParser.new do |opts|
          opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
          opts.on('-s', '--silent', 'Silent mode')
        end.parse!(into: options)
      end
    end
  end
end
