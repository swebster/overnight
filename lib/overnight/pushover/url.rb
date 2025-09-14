# frozen_string_literal: true

require 'uri'

module Overnight
  class Pushover
    # methods to generate Pushover URLs
    module Url
      private_class_method def self.join(*args)
        path = File.join(args.push("#{args.pop}.json"))
        URI.join('https://api.pushover.net/1/', path)
      end

      def self.groups(*)
        join('groups', *)
      end

      def self.messages
        join('messages')
      end

      def self.receipts(receipt)
        join('receipts', receipt)
      end

      def self.validate_user
        join('users', 'validate')
      end
    end
  end
end
