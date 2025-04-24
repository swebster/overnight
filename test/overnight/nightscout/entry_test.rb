# frozen_string_literal: true

require 'minitest/autorun'
require 'overnight/nightscout/entry'

class TestEntry < Minitest::Test
  def setup
    @contract = Overnight::Nightscout::Entry::Contract.new
    @sample_data = load_sample_data
  end

  def test_contract
    @sample_data.each do |element|
      result = @contract.call(element)
      refute(result.failure?, result.errors.to_h)
    end
  end

  private

  def load_sample_data
    sample_file = 'test/overnight/nightscout/data/entry.json'
    JSON.parse(File.read(sample_file), symbolize_names: true)
  end
end
