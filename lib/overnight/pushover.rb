# frozen_string_literal: true

require 'overnight/pushover/client'

module Overnight
  # provides a wrapper around the Pushover API
  class Pushover
    def list_groups
      groups = Client.list_groups
      if groups.empty?
        puts 'No groups currently exist'
      else
        puts 'The following groups are available:'
        puts groups
      end
    end

    def find_group_key(group_name)
      groups = Client.list_groups
      group = groups.find { it[:name] == group_name }
      group[:group] if group
    end

    def create_group(group_name)
      group_key = Client.create_group(group_name)
      puts "Group '#{group_name}' created with key '#{group_key}'"
      group_key
    end

    def list_users(group_name, group_key)
      users = Client.list_users(group_key:)
      if users.empty?
        puts "The '#{group_name}' group has no members"
      else
        puts "The following users are members of the '#{group_name}' group:"
        puts users
      end
    end

    def create_group_or_list_users(group_name)
      group_key = find_group_key(group_name)
      if group_key.nil?
        create_group(group_name)
      else
        list_users(group_name, group_key)
      end
    end

    def add_user(group_name, user_key, user_name)
      group_key = find_group_key(group_name)
      raise Error, "The '#{group_name}' group does not exist" if group_key.nil?

      Client.add_user(group_key:, user_key:, user_name:)
      puts "User '#{user_name}' has been added to the '#{group_name}' group"
    end

    def group_notifications?
      user_group.size > 1
    end

    def post(...)
      Client.post(...)
    end

    def check_status(receipt)
      status = Client.status(receipt:)
      status if status[:acknowledged] == 1 || status[:expired] == 1
    end

    def publish_response(status)
      options = { priority: -1 }
      if status[:acknowledged] == 1
        user_key = status[:acknowledged_by]
        other_users = user_group.keys - [user_key]
        options[:user] = other_users.join(',')
      end
      Client.post(generate_response(status), **options)
    end

    private

    def generate_response(status)
      if status[:acknowledged] == 1
        user_key = status[:acknowledged_by]
        user_name = user_group.dig(user_key, :memo) || 'unknown user'
        time = Time.at(status[:acknowledged_at]).strftime('%F %T')
        "Emergency acknowledged by #{user_name} at #{time}"
      else # status[:expired] == 1
        time = Time.at(status[:expires_at]).strftime('%F %T')
        "Emergency notification expired at #{time} without being acknowledged"
      end
    end

    def user_group
      @user_group ||=
        if Client.group_key?(user_key: USER_KEY)
          users = Client.list_users(group_key: USER_KEY)
          users.to_h { [it[:user], it.except(:user)] }
        else
          {}
        end
    end
  end
end
