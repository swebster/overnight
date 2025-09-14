# frozen_string_literal: true

require 'json'
require 'overnight/http_client'
require 'overnight/pushover/config'
require 'overnight/pushover/url'
require 'overnight/pushover/validator'

module Overnight
  class Pushover
    # generic wrapper for all Pushover API requests and responses
    module Client
      extend HTTPClient

      def self.create_group(name)
        parse_hash(run(Url.groups, method: :post, params: { name: }))[:group]
      end

      def self.list_groups
        parse_hash(run(Url.groups))[:groups]
      end

      def self.add_user(group_key:, user_key:, user_name:)
        Validator.validate_key(group_key, type: :group)
        Validator.validate_key(user_key,  type: :user)
        url = Url.groups(group_key, 'add_user')
        run(url, method: :post, params: { user: user_key, memo: user_name })
      end

      def self.list_users(group_key:)
        Validator.validate_key(group_key, type: :group)
        parse_hash(run(Url.groups(group_key)))[:users]
      end

      def self.group_key?(user_key:)
        url = Url.validate_user
        parse_hash(run(url, method: :post, params: { user: user_key }))[:group] == 1
      end

      def self.post(message, user: USER_KEY, title: nil, priority: 0)
        params = { user:, message:, priority: }
        # retry urgent messages every 60 seconds for 30 minutes until acknowledged
        params.update({ retry: 60, expire: 1800 }) if priority == 2
        options = { sound: sound_by(priority), title: title || title_by(priority) }
        params.update(options.compact)
        response_body = run(Url.messages, method: :post, params:)
        parse_hash(response_body)[:receipt] unless response_body.nil?
      end

      def self.status(receipt:)
        Validator.validate_key(receipt, type: :receipt)
        parse_hash(run(Url.receipts(receipt)))
      end

      def self.sound_by(priority)
        case priority
        when 2 then 'echo'
        when 1 then 'pushover'
        when 0 then 'vibrate'
        end
      end

      def self.title_by(priority)
        case priority
        when  2 then 'Emergency'
        when  1 then 'Warning'
        when  0 then 'Notice'
        when -1 then 'Update'
        end
      end

      def self.run(url, method: :get, params: {})
        params[:token] = APP_TOKEN
        headers = { Accept: 'application/json' }
        request = Typhoeus::Request.new(url, method:, params:, headers:)
        request.run.tap { |response| validate_http(response) }.body
      end

      def self.parse_hash(response_body)
        JSON.parse(response_body, symbolize_names: true)
      end
    end
  end
end
