# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/sample/predictor'

Error      = Overnight::Nightscout::Error
EntryRange = Overnight::Nightscout::Sample::EntryRange
Predictor  = Overnight::Nightscout::Sample::Predictor

class TestPredictor < Minitest::Test
  LOW_NOTICE    = Predictor::LOW_NOTICE
  HIGH_NOTICE   = Predictor::HIGH_NOTICE
  LOW_DURATION  = Predictor::LOW_DURATION
  HIGH_DURATION = Predictor::HIGH_DURATION

  RANGE_GLUCOSE = {
    urgent_low: 54,
    low: 79,
    normal: 108,
    high: 181,
    urgent_high: 247
  }.freeze

  def test_empty_raises_error
    error = assert_raises(Error) { create_predictor([]) }
    assert_equal 'No glucose entries provided', error.message
  end

  def test_find_nothing_when_normal
    er = create_er_minutes([:normal], [120])
    pred = create_predictor(er)
    assert_equal [], pred.find_predicted([:low])
  end

  def test_find_predicted_low
    er = create_er_minutes(%i[normal low normal], [15, 30, 75])
    pred = create_predictor(er)
    assert_equal er[1..1], pred.find_predicted([:low])
  end

  def test_find_predicted_lows
    er = create_er_minutes(%i[normal low urgent_low low], [75, 20, 5, 20])
    pred = create_predictor(er)
    assert_equal er[1..3], pred.find_predicted(%i[low urgent_low])
  end

  def test_low_not_predicted_when_normal
    er = create_er_minutes([:normal], [120])
    pred = create_predictor(er)
    assert_equal false, pred.low_predicted?
  end

  def test_low_not_predicted_when_later
    er = create_er_seconds(%i[normal low], [LOW_NOTICE + 1, LOW_DURATION + 1])
    pred = create_predictor(er)
    assert_equal false, pred.low_predicted?
  end

  def test_low_not_predicted_when_brief
    er = create_er_seconds(%i[normal low], [LOW_NOTICE, LOW_DURATION])
    pred = create_predictor(er)
    assert_equal false, pred.low_predicted?
  end

  def test_low_predicted
    er = create_er_seconds(%i[normal low], [LOW_NOTICE, LOW_DURATION + 1])
    pred = create_predictor(er)
    assert_equal true, pred.low_predicted?
  end

  def test_high_not_predicted_when_normal
    er = create_er_minutes([:normal], [120])
    pred = create_predictor(er)
    assert_equal false, pred.high_predicted?
  end

  def test_high_not_predicted_when_later
    er = create_er_seconds(%i[normal high], [HIGH_NOTICE + 1, HIGH_DURATION + 1])
    pred = create_predictor(er)
    assert_equal false, pred.high_predicted?
  end

  def test_high_not_predicted_when_brief
    er = create_er_seconds(%i[normal high], [HIGH_NOTICE, HIGH_DURATION])
    pred = create_predictor(er)
    assert_equal false, pred.high_predicted?
  end

  def test_high_predicted
    er = create_er_seconds(%i[normal high], [HIGH_NOTICE, HIGH_DURATION + 1])
    pred = create_predictor(er)
    assert_equal true, pred.high_predicted?
  end

  private

  def create_er_seconds(ranges, durations_seconds)
    create_er_minutes(ranges, durations_seconds.map { it / 60.0 })
  end

  def create_er_minutes(ranges, durations)
    start_time = Time.now
    ranges.each_with_index.map do |range, index|
      time = start_time + durations.take(index).sum * 60
      duration = (durations[index] * 60).round
      EntryRange.new(time, RANGE_GLUCOSE[range], range, duration)
    end
  end

  def create_predictor(entry_ranges)
    Predictor.new(entry_ranges, [])
  end
end
