# frozen_string_literal: true

require 'climate_control'
require 'minitest/autorun'
require 'overnight/env'
require 'tempfile'

Env   = Overnight::Env
Error = Overnight::Error

class TestEnv < Minitest::Test
  REQUIRED_KEY         = 'REQUIRED_KEY'
  REQUIRED_SECRET      = 'REQUIRED_SECRET'
  REQUIRED_SECRET_FILE = "#{REQUIRED_SECRET}_FILE".freeze

  def test_identifies_missing_key
    assert_equal false, ENV.key?(REQUIRED_KEY)
    args = { keys: [REQUIRED_KEY], secrets: [] }
    error = assert_raises(Dotenv::MissingKeys) { Env.require_keys(**args) }
    assert_match(/"#{REQUIRED_KEY}"/, error.message)
  end

  def test_recognises_required_key
    ClimateControl.modify({ REQUIRED_KEY => 'some_value' }) do
      assert_equal true, ENV.key?(REQUIRED_KEY)
      args = { keys: [REQUIRED_KEY], secrets: [] }
      Env.require_keys(**args) # should not raise Dotenv::MissingKeys
    end
  end

  def test_identifies_missing_secret
    assert_equal false, ENV.key?(REQUIRED_SECRET)
    args = { keys: [], secrets: [REQUIRED_SECRET] }
    error = assert_raises(Dotenv::MissingKeys) { Env.require_keys(**args) }
    assert_match(/"#{REQUIRED_SECRET}"/, error.message)
  end

  def test_recognises_required_secret
    ClimateControl.modify({ REQUIRED_SECRET => 'some_value' }) do
      assert_equal true, ENV.key?(REQUIRED_SECRET)
      args = { keys: [], secrets: [REQUIRED_SECRET] }
      Env.require_keys(**args) # should not raise Dotenv::MissingKeys
    end
  end

  def test_recognises_required_secret_file
    ClimateControl.modify({ REQUIRED_SECRET_FILE => 'some_path' }) do
      assert_equal true, ENV.key?(REQUIRED_SECRET_FILE)
      args = { keys: [], secrets: [REQUIRED_SECRET] }
      Env.require_keys(**args) # should not raise Dotenv::MissingKeys
    end
  end

  def test_load_missing_secret
    assert_equal false, ENV.key?(REQUIRED_SECRET_FILE)
    error = assert_raises(Error) { Env.load_secret(key: REQUIRED_SECRET) }
    assert_match(/\b#{REQUIRED_SECRET_FILE}\b/, error.message)
  end

  def test_load_inaccessible_secret
    secret_path = 'some_path'
    ClimateControl.modify({ REQUIRED_SECRET_FILE => secret_path }) do
      assert_equal true, ENV.key?(REQUIRED_SECRET_FILE)
      error = assert_raises(Error) { Env.load_secret(key: REQUIRED_SECRET) }
      assert_match(/\b#{REQUIRED_SECRET_FILE}\b/, error.message)
      assert_match(/\b#{secret_path}\b/, error.message)
    end
  end

  def test_load_secret
    secret_value = 'some_value'
    Tempfile.create do |secret_file|
      secret_file.write(secret_value)
      secret_file.close
      ClimateControl.modify({ REQUIRED_SECRET_FILE => secret_file.path }) do
        assert_equal true, ENV.key?(REQUIRED_SECRET_FILE)
        assert_equal secret_value, Env.load_secret(key: REQUIRED_SECRET)
      end
    end
  end
end
