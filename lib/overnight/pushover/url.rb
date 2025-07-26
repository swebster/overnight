# frozen_string_literal: true

require 'uri'

module Overnight
  module Pushover
    # methods to generate Pushover URLs
    module Url
      private_class_method def self.join(*args)
        path = File.join(args.push("#{args.pop}.json"))
        URI.join('https://api.pushover.net/1/', path)
      end

      def self.groups(*)
        join('groups', *)
      end

      def self.messages(*)
        join('messages', *)
      end
    end
  end
end
