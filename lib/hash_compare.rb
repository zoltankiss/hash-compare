# frozen_string_literal: true

require_relative "../lib/traversal"

class HashCompare
  class << self
    # This code is unfortunately not very pretty. It was
    # intended as a interesting pontential real-world use case for my other
    # code, given how similar the output is to the format that
    # git uses. (e.g git rebase conflict). Could be very useful for large
    # hashes.
    #
    # ex output:
    #
    # a =>
    #   <<<<<< hash1
    #   =======
    #   a3
    #   >>>>>> hash2
    #   c =>
    #     <<<<<< hash1
    #     e
    #     d1
    #     =======
    #     d
    #     >>>>>> hash2
    # b =>
    #   <<<<<< hash1
    #   c
    #   =======
    #   >>>>>> hash2
    def to_s(obj1, obj2)
      diff = diff(obj1, obj2, shallow: false)
      already_executed = {}
      lines = []

      diff.to_a.sort { |e| e.length }.reverse.each do |e|
        k = e.first
        v = e.last

        k.length.times do |k1|
          prefix = k[0..k1]
          next if already_executed[prefix]
          lines << "#{'  '*k1}#{k[k1]} =>"
          if prefix.join("") != k && !already_executed[prefix] && diff[prefix]
            lines << "#{'  '*(k1+1)}<<<<<< hash1"
            diff[prefix].select { |k2, v2| v2 == "-" }.keys.each do |hash1e|
              lines << "#{'  '*(k1+1)}#{hash1e}"
            end
            lines << "#{'  '*(k1+1)}======="
            diff[prefix].select { |k2, v2| v2 == "+" }.keys.each do |hash1e|
              lines << "#{'  '*(k1+1)}#{hash1e}"
            end
            lines << "#{'  '*(k1+1)}>>>>>> hash2"
          end
          already_executed[prefix] = true
        end
      end

      lines.join("\n")
    end

    def shallow_diff(obj1, obj2)
      keys_added = obj2.keys - obj1.keys
      keys_subtracted = obj1.keys - obj2.keys
      keys_diff = keys_added.to_h { |e| [e, "+"] }.merge(
        keys_subtracted.to_h { |e| [e, "-"] }
      )

      vals_added = obj2.values - obj1.values
      vals_subtracted = obj1.values - obj2.values
      vals_diff = vals_added.to_h { |e| [e, "+"] }.merge(
        vals_subtracted.to_h { |e| [e, "-"] }
      )

      { keys_diff: keys_diff, vals_diff: vals_diff }
    end

    def diff(obj1, obj2, shallow: false)
      return shallow_diff(obj1, obj2) if shallow

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