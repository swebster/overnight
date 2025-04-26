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
end
