# frozen_string_literal: true

require 'overnight/pushover/client'

module Overnight
  # provides a wrapper around the Pushover API
  module Pushover
    def self.list_groups
      groups = Client.list_groups
      if groups.empty?
        puts 'No groups currently exist'
      else
        puts 'The following groups are available:'
        puts groups
      end
    end

    def self.find_group_key(group_name)
      groups = Client.list_groups
      group = groups.find { it[:name] == group_name }
      group[:group] if group
    end

    def self.create_group(group_name)
      group_key = Client.create_group(group_name)
      puts "Group '#{group_name}' created with key '#{group_key}'"
      group_key
    end

    def self.list_users(group_name, group_key)
      users = Client.list_users(group_key:)
      if users.empty?
        puts "The '#{group_name}' group has no members"
      else
        puts "The following users are members of the '#{group_name}' group:"
        puts users
      end
    end

    def self.create_group_or_list_users(group_name)
      group_key = find_group_key(group_name)
      if group_key.nil?
        create_group(group_name)
      else
        list_users(group_name, group_key)
      end
    end

    def self.add_user(group_name, user_key, user_name)
      group_key = find_group_key(group_name)
      raise Error, "The '#{group_name}' group does not exist" if group_key.nil?

      Client.add_user(group_key:, user_key:, user_name:)
      puts "User '#{user_name}' has been added to the '#{group_name}' group"
    end

    def self.post(...)
      Client.post(...)
    end

    def self.check_status(receipt)
      status = Client.status(receipt:)
      status if status[:acknowledged] == 1 || status[:expired] == 1
    end
  end
end
