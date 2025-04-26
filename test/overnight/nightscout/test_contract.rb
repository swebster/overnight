# frozen_string_literal: true

require 'overnight/utils'

module TestContract
  def setup
    @contract = contract_type.new
    @sample_data = load_sample_data
  end

  private

  def type
    self.class.name[/^Test(\w+)/, 1]
  end

  def contract_type
    class_name = "Overnight::Nightscout::#{type}::Contract"
    Class.const_get(class_name)
  end

  def load_sample_data
    snake_case_type = Overnight::Utils.snake_case(type)
    sample_file = "test/overnight/nightscout/data/#{snake_case_type}.json"
    JSON.parse(File.read(sample_file), symbolize_names: true)
  end
end

module TestHashContract
  include TestContract

  def test_contract
    result = @contract.call(@sample_data)
    refute(result.failure?, result.errors.to_h)
  end
end

module TestArrayContract
  include TestContract

  def test_contract
    @sample_data.each do |element|
      result = @contract.call(element)
      refute(result.failure?, result.errors.to_h)
    end
  end
end
