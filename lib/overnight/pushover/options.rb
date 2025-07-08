# frozen_string_literal: true

require 'optparse'
require 'overnight/pushover/config'
require 'overnight/pushover/validator'

module Overnight
  module Pushover
    # a simple command-line options parser
    module Options
      def self.create_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
          opts.on('-g', '--group GROUP_NAME', 'Name of the Pushover group')
          opts.on('-u', '--user  USER_KEY', 'User to add to the group')
          opts.on('-n', '--name  USER_NAME', 'Name of the added user')
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
          if options.key?(:user)
            assert_present(options, %i[group name])
            Validator.validate_key(options[:user], type: :user)
          end
          assert_present(options, %i[user]) if options.key?(:name)
        end
      end
    end
  end
end
