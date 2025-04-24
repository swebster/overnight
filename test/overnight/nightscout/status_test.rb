# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/status'

class TestStatus < Minitest::Test
  def setup
    @contract = Overnight::Nightscout::Status::Contract.new
    @sample_data = load_sample_data
  end

  def test_contract
    result = @contract.call(@sample_data)
    refute(result.failure?, result.errors.to_h)
  end

  private

  def load_sample_data
    sample_file = 'test/overnight/nightscout/data/status.json'
    JSON.parse(File.read(sample_file), symbolize_names: true)
  end
end
