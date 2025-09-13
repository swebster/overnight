# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/pushover/url'

Url = Overnight::Pushover::Url

class TestPushoverUrl < Minitest::Test
  def test_groups
    url = 'https://api.pushover.net/1/groups.json'
    assert_equal url, Url.groups.to_s
  end

  def test_group_key
    url = 'https://api.pushover.net/1/groups/test_group.json'
    assert_equal url, Url.groups('test_group').to_s
  end

  def test_group_user
    url = 'https://api.pushover.net/1/groups/test_group/add_user.json'
    assert_equal url, Url.groups('test_group', 'add_user').to_s
  end

  def test_messages
    url = 'https://api.pushover.net/1/messages.json'
    assert_equal url, Url.messages.to_s
  end

  def test_receipts
    url = 'https://api.pushover.net/1/receipts/test_receipt.json'
    assert_equal url, Url.receipts('test_receipt').to_s
  end

  def test_validate_user
    url = 'https://api.pushover.net/1/users/validate.json'
    assert_equal url, Url.validate_user.to_s
  end
end
