# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/utils'

Utils = Overnight::Utils

class TestUtils < Minitest::Test
  def test_snake_case
    assert_equal 'test_utils', Utils.snake_case(self.class.name)
  end

  def test_snake_sym
    assert_equal :test_utils, Utils.snake_sym(self.class.name)
  end

  def test_hours_in_daytime_range
    expected_range = Set.new([*(9..16)])
    assert_equal expected_range, Utils.hours_in_range(9, 17)
  end

  def test_hours_in_overnight_range
    expected_range = Set.new([*(21..23), *(0..4)])
    assert_equal expected_range, Utils.hours_in_range(21, 5)
  end

  def test_hours_in_round_the_clock_range
    expected_range = Set.new([*(0..23)])
    assert_equal expected_range, Utils.hours_in_range(15, 15)
  end
end
