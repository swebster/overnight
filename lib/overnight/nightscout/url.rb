# frozen_string_literal: true

require 'uri'
require 'overnight/nightscout/config'

module Overnight
  class Nightscout
    # methods to generate Nightscout URLs
    module Url
      def self.base
        URI::HTTPS.build({ host: Nightscout::HOST, port: Nightscout::PORT, path: '/api/' })
      end

      def self.join(path_segment, api_version)
        URI.join(base, File.join(api_version, '/'), path_segment)
      end
    end
  end
end
