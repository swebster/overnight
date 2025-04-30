# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/sample/synchronizer'

Synchronizer = Overnight::Nightscout::Sample::Synchronizer

class TestSynchronizer < Minitest::Test
  def test_mistimed_early
    sync = create_synchronizer(sample_offset: Synchronizer::MINIMUM_DELAY - 0.1)
    assert_equal true, sync.mistimed?
  end

  def test_not_mistimed_early
    sync = create_synchronizer(sample_offset: Synchronizer::MINIMUM_DELAY)
    assert_equal false, sync.mistimed?
  end

  def test_not_mistimed_late
    sync = create_synchronizer(sample_offset: Synchronizer::MAXIMUM_DELAY)
    assert_equal false, sync.mistimed?
  end

  def test_mistimed_late
    sync = create_synchronizer(sample_offset: Synchronizer::MAXIMUM_DELAY + 0.1)
    assert_equal true, sync.mistimed?
  end

  def test_missed_no_samples
    sync = create_synchronizer(sample_offset: Synchronizer::LOOP_INTERVAL - 0.1)
    assert_equal 0, sync.missed_samples
  end

  def test_missed_one_sample
    sync = create_synchronizer(sample_offset: Synchronizer::LOOP_INTERVAL)
    assert_equal 1, sync.missed_samples
  end

  def test_missed_negative_samples
    sync = create_synchronizer(sample_offset: Synchronizer::LOOP_INTERVAL * -1)
    assert_equal 0, sync.missed_samples
  end

  def test_next_sample
    sync = create_synchronizer
    next_sample_time = sync.sample_time + Synchronizer::LOOP_INTERVAL
    assert_equal next_sample_time, sync.next_sample
  end

  def test_next_sample_after_early
    sync = create_synchronizer(sample_offset: Synchronizer::MINIMUM_DELAY - 0.1)
    next_sample_time = sync.sample_time + Synchronizer::LOOP_INTERVAL
    assert_equal next_sample_time, sync.next_sample
  end

  def test_next_sample_after_late
    sync = create_synchronizer(sample_offset: Synchronizer::MAXIMUM_DELAY + 0.1)
    next_sample_time = sync.sample_time + Synchronizer::LOOP_INTERVAL
    assert_equal next_sample_time, sync.next_sample
  end

  def test_next_sample_after_miss
    sync = create_synchronizer(sample_offset: Synchronizer::LOOP_INTERVAL)
    next_sample_time = sync.sample_time + Synchronizer::LOOP_INTERVAL * 2
    assert_equal next_sample_time, sync.next_sample
  end

  def test_next_time
    sync = create_synchronizer(server_offset: 0)
    next_sample_time = sync.next_sample + Synchronizer::TARGET_DELAY
    assert_equal next_sample_time, sync.next_time
  end

  def test_next_time_with_latency
    latency = 0.5
    sync = create_synchronizer(server_offset: latency)
    next_sample_time = sync.next_sample - latency + Synchronizer::TARGET_DELAY
    assert_equal next_sample_time, sync.next_time
  end

  private

  def request_time = Time.new(2025, 3, 31, 11, 59, 59)

  def create_synchronizer(server_offset: 1, sample_offset: nil)
    server_time = request_time + server_offset
    sample_time = request_time + server_offset - (sample_offset || Synchronizer::TARGET_DELAY)
    Synchronizer.new(request_time, server_time, sample_time)
  end
end
