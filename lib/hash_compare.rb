# frozen_string_literal: true

require_relative "../lib/traversal"

class HashCompare
  class << self
    def diff(obj1, obj2, shallow: false)
      h = Traversal.traverse(obj1)
      h2 = Traversal.traverse(obj2)
      h3 = {}

      h.each do |prefix, vals|
        h3[prefix] ||= {}
        vals.each do |val|
          h3[prefix][val] = "-" if !h2[prefix] || !h2[prefix].include?(val)
        end
      end

      h2.each do |prefix, vals|
        h3[prefix] ||= {}
        vals.each do |val|
          h3[prefix][val] = "+" if !h[prefix] || !h[prefix].include?(val)
        end
      end

      h3.select {|k,v| !v.empty? }
    end
  end
end