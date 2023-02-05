# frozen_string_literal: true

gem "minitest", "~> 5.4"
require "minitest/autorun"
require_relative "../lib/hash_compare"

class HashCompareTest < Minitest::Test
  def test_to_s
    hash1 = {
      "a" => [
        "a1",
        "a2",
        "a3",
        {
          "c" => ["d", true, false]
        }
      ]
    }

    hash2 = {
      "a" => [
        "a1",
        "a2",
        "a4",
        {
          "c" => %w[e d1]
        }
      ],
      "b" => "c"
    }

    results = <<~STRING
      a =>
        <<<<<< hash1
        a3
        =======
        a4
        >>>>>> hash2
        c =>
          <<<<<< hash1
          d
          true
          false
          =======
          e
          d1
          >>>>>> hash2
      b =>
        <<<<<< hash1
        =======
        c
        >>>>>> hash2
    STRING

    assert_equal results.strip, HashCompare.to_s(hash1, hash2).strip
  end

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
          "c" => %w[e d1]
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
    hash1 = {
      "a" => "b",
      "b" => "c1",
      "c" => "c"
    }

    hash2 = {
      "a" => "b",
      "b" => "c",
      "d" => "d"
    }

    diff = {
      keys_diff: { "c" => "-", "d" => "+" },
      vals_diff: { "c1" => "-", "d" => "+" }
    }

    assert_equal diff, HashCompare.diff(hash1, hash2, shallow: true)
  end

  def test_only_string_boolean_number_array_hash_allowed_as_values
    invalid_obj_klass = Class.new

    hash1 = {
      "a" => "b",
      "b" => invalid_obj_klass.new,
      "c" => "c"
    }

    hash2 = {
      "a" => "b",
      "b" => "c",
      "d" => "d"
    }

    assert_raises(Traversal::InvalidHashValueError) do
      HashCompare.diff(hash1, hash2, shallow: false)
    end
  end
end
