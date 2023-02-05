# frozen_string_literal: true

gem "minitest", "~> 5.4"
require "minitest/autorun"
require_relative "../lib/hash_compare"

class HashCompareTest < Minitest::Test
  def test_hash_compare_deep
    hash1 = {
      "a" => [
        "a1",
        "a2",
        "a3",
        {
          "c" => ["d"]
        }
      ]
    }

    hash2 = {
      "a" => [
        "a1",
        "a2",
        {
          "c" => ["e", "d1"]
        }
      ],
      "b" => "c"
    }

    diff = {
      %w[a] => { "a3" => "-" },
      %w[a c] => { "d" => "-", "e" => "+", "d1" => "+" },
      %w[b] => { "c" => "+" }
    }

    assert_equal diff, HashCompare.diff(hash1, hash2, shallow: false)
  end

  def test_hash_compare_shallow
  end
end
