# frozen_string_literal: true

# class that traverses a nested object e.g hash of hashes,
# and returns a hash where the keys are every path through the object.
# e.g
#
# irb> Traversal.traverse({ "a" => ["b", { "c" => "d" }] })
# {["a"]=>["b"], ["a", "c"]=>["d"]}
class Traversal
  class InvalidHashValueError < StandardError
  end

  class << self
    def traverse(obj)
      tracker_hash = {}
      traverse_helper(obj, [], tracker_hash)
      tracker_hash
    end

    private

    def basic_obj?(obj)
      !obj.respond_to?(:each)
    end

    def validate_obj!(obj)
      return if [TrueClass, FalseClass, String, Integer, Hash, Array].include?(obj.class)

      raise InvalidHashValueError
    end

    # rubocop:disable Metrics/MethodLength
    def traverse_helper(obj, prefix, tracker)
      validate_obj!(obj)

      if basic_obj?(obj)
        tracker[prefix] ||= []
        tracker[prefix] << obj
      elsif obj.is_a?(Hash)
        obj.each do |k, v|
          traverse_helper(v, prefix.clone.concat([k]), tracker)
        end
      elsif obj.is_a?(Array)
        obj.each do |e|
          traverse_helper(e, prefix, tracker)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
