# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/status/glucose_ranges'

class TestGlucoseRanges < Minitest::Test
  UPPER_BOUND_URGENT_LOW  =  56
  UPPER_BOUND_LOW         =  81
  LOWER_BOUND_HIGH        = 180
  LOWER_BOUND_URGENT_HIGH = 247

  GLUCOSE_RANGES = Overnight::Nightscout::Status::GlucoseRanges.new({
             bgLow: UPPER_BOUND_URGENT_LOW,
    bgTargetBottom: UPPER_BOUND_LOW,
       bgTargetTop: LOWER_BOUND_HIGH,
            bgHigh: LOWER_BOUND_URGENT_HIGH
  }).freeze

  def find(glucose)
    GLUCOSE_RANGES.find(glucose)&.name
  end

  def test_lower_bound_urgent_low
    assert_equal :urgent_low, find(UPPER_BOUND_URGENT_LOW - 0.6)
  end

  def test_upper_bound_urgent_low
    assert_equal :urgent_low, find(UPPER_BOUND_URGENT_LOW + 0.4)
  end

  def test_lower_bound_low
    assert_equal :low, find(UPPER_BOUND_URGENT_LOW + 0.6)
  end

  def test_upper_bound_low
    assert_equal :low, find(UPPER_BOUND_LOW + 0.4)
  end

  def test_lower_bound_normal
    assert_equal :normal, find(UPPER_BOUND_LOW + 0.6)
  end

  def test_upper_bound_normal
    assert_equal :normal, find(LOWER_BOUND_HIGH - 0.6)
  end

  def test_lower_bound_high
    assert_equal :high, find(LOWER_BOUND_HIGH - 0.4)
  end

  def test_upper_bound_high
    assert_equal :high, find(LOWER_BOUND_URGENT_HIGH - 0.6)
  end

  def test_lower_bound_urgent_high
    assert_equal :urgent_high, find(LOWER_BOUND_URGENT_HIGH - 0.4)
  end

  def test_upper_bound_urgent_high
    assert_equal :urgent_high, find(LOWER_BOUND_URGENT_HIGH + 0.6)
  end
end
