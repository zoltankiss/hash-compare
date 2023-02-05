# frozen_string_literal: true

require_relative "../lib/traversal"

# class with methods to discover the diff between two
# objects, in particular, two hashes
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
    # rubocop:disable Style/SymbolProc, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def to_s(obj1, obj2)
      diff = diff(obj1, obj2, shallow: false)
      already_executed = {}
      lines = []

      diff.to_a.sort { |el| el.length }.reverse.each do |e|
        k = e.first

        k.length.times do |k1|
          prefix = k[0..k1]
          next if already_executed[prefix]

          lines << "#{'  ' * k1}#{k[k1]} =>"
          if prefix.join("") != k && !already_executed[prefix] && diff[prefix]
            lines << "#{'  ' * (k1 + 1)}<<<<<< hash1"
            diff[prefix].select { |_k2, v2| v2 == "-" }.each_key do |hash1e|
              lines << "#{'  ' * (k1 + 1)}#{hash1e}"
            end
            lines << "#{'  ' * (k1 + 1)}======="
            diff[prefix].select { |_k2, v2| v2 == "+" }.each_key do |hash1e|
              lines << "#{'  ' * (k1 + 1)}#{hash1e}"
            end
            lines << "#{'  ' * (k1 + 1)}>>>>>> hash2"
          end
          already_executed[prefix] = true
        end
      end

      lines.join("\n")
    end
    # rubocop:enable Style/SymbolProc, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def keys_added(obj1, obj2)
      keys_added = obj2.keys - obj1.keys
      keys_subtracted = obj1.keys - obj2.keys
      keys_added.to_h { |e| [e, "+"] }.merge(
        keys_subtracted.to_h { |e| [e, "-"] }
      )
    end

    def vals_diff(obj1, obj2)
      vals_added = obj2.values - obj1.values
      vals_subtracted = obj1.values - obj2.values
      vals_added.to_h { |e| [e, "+"] }.merge(
        vals_subtracted.to_h { |e| [e, "-"] }
      )
    end

    def shallow_diff(obj1, obj2)
      { keys_diff: keys_added(obj1, obj2), vals_diff: vals_diff(obj1, obj2) }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
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

      h3.reject { |_k, v| v.empty? }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  end
end
