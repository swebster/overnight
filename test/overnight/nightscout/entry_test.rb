# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/entry'
require 'test/overnight/nightscout/test_contract'

class TestEntry < Minitest::Test
  include TestArrayContract
end
