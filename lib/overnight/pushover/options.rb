# frozen_string_literal: true

require 'optparse'
require 'overnight/pushover/config'

module Overnight
  class Pushover
    # a simple command-line options parser
    module Options
      def self.create_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
          opts.on('-g', '--group    GROUP_NAME', 'Name of the Pushover group')
          opts.on('-u', '--user     USER_KEY',   'User to add to the group')
          opts.on('-n', '--name     USER_NAME',  'Name of the added user')
          opts.on('-m', '--message  MESSAGE',    'Message to post to Pushover')
          opts.on('-p', '--priority PRIORITY', Integer, 'Message priority')
        end
      end

      def self.assert_present(options, keys)
        keys.each do |key|
          raise Error, "Option missing: #{key}" unless options.key?(key)
        end
      end

      def self.parse
        {}.tap do |options|
          create_parser.parse!(into: options)
          assert_present(options, %i[group name]) if options.key?(:user)
          assert_present(options, %i[user])       if options.key?(:name)
          assert_present(options, %i[message])    if options.key?(:priority)
        end
      end
    end
  end
end
