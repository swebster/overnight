# frozen_string_literal: true

require 'json'
require 'overnight/http_client'
require 'overnight/pushover/config'
require 'overnight/pushover/validator'

module Overnight
  module Pushover
    # generic wrapper for all Pushover API requests and responses
    module Client
      extend HTTPClient

      def self.create_group(name)
        url = 'https://api.pushover.net/1/groups.json'
        parse_hash(run(url, method: :post, params: { name: }), :group)
      end

      def self.list_groups
        parse_hash(run('https://api.pushover.net/1/groups.json'), :groups)
      end

      def self.add_user(group_key:, user_key:, user_name:)
        Validator.validate_key(group_key, type: :group)
        Validator.validate_key(user_key,  type: :user)
        url = "https://api.pushover.net/1/groups/#{group_key}/add_user.json"
        run(url, method: :post, params: { user: user_key, memo: user_name })
      end

      def self.list_users(group_key:)
        Validator.validate_key(group_key, type: :group)
        url = "https://api.pushover.net/1/groups/#{group_key}.json"
        parse_hash(run(url), :users)
      end

      def self.post(message, title:, priority: 0)
        url = 'https://api.pushover.net/1/messages.json'
        params = { user: USER_KEY, title:, message:, priority: }
        # retry urgent messages every 60 seconds for 30 minutes until acknowledged
        params.update({ retry: 60, expire: 1800 }) if priority == 2
        sound = notification_sound(priority)
        params[:sound] = sound unless sound.nil?
        run(url, method: :post, params:)
      end

      def self.notification_sound(priority)
        case priority
        when 2 then 'echo'
        when 1 then 'pushover'
        when 0 then 'vibrate'
        end
      end

      def self.run(url, method: :get, params: {})
        params[:token] = APP_TOKEN
        headers = { Accept: 'application/json' }
        request = Typhoeus::Request.new(url, method:, params:, headers:)
        request.run.tap { |response| validate_http(response) }.body
      end

      def self.parse_hash(response_body, key)
        JSON.parse(response_body, symbolize_names: true)[key]
      end
    end
  end
end
