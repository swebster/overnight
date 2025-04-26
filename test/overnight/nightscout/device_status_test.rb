# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/device_status'
require 'test/overnight/nightscout/test_contract'

class TestDeviceStatus < Minitest::Test
  include TestArrayContract
end
