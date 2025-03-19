# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/status/glucose_ranges'

class TestGlucoseRanges < Minitest::Test
  def find(glucose)
    @glucose_ranges.find(glucose)&.name
  end

  def setup
    @glucose_ranges = Overnight::Nightscout::Status::GlucoseRanges.new(
      {
        bgLow: low, bgTargetBottom: bottom, bgTargetTop: top, bgHigh: high
      }
    )
  end

  def test_lower_bound_urgent_low
    assert_equal :urgent_low, find(low - 0.6)
  end

  def test_upper_bound_urgent_low
    assert_equal :urgent_low, find(low + 0.4)
  end

  def test_lower_bound_low
    assert_equal :low, find(low + 0.6)
  end

  def test_upper_bound_low
    assert_equal :low, find(bottom + 0.4)
  end

  def test_lower_bound_normal
    assert_equal :normal, find(bottom + 0.6)
  end

  def test_upper_bound_normal
    assert_equal :normal, find(top - 0.6)
  end

  def test_lower_bound_high
    assert_equal :high, find(top - 0.4)
  end

  def test_upper_bound_high
    assert_equal :high, find(high - 0.6)
  end

  def test_lower_bound_urgent_high
    assert_equal :urgent_high, find(high - 0.4)
  end

  def test_upper_bound_urgent_high
    assert_equal :urgent_high, find(high + 0.6)
  end

  private

  def low = 56
  def bottom = 81
  def top = 180
  def high = 247
end
