# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/status'
require 'test/overnight/nightscout/test_contract'

class TestStatus < Minitest::Test
  include TestHashContract
end
