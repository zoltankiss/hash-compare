# frozen_string_literal: true

gem 'minitest', '~> 5.4'
require 'minitest/autorun'
require_relative '../lib/hash_compare'

class HashCompareTest < Minitest::Test
  def test_class_exists
    assert HashCompare.is_a?(Class)
  end
end
