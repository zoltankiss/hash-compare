class Traversal
  class << self
    def traverse(obj)
      tracker_hash = {}
      traverse_helper(obj, [], tracker_hash)
      tracker_hash
    end

    private

    def basic_obj?(e)
      !e.respond_to?(:each)
    end

    def traverse_helper(obj, prefix, tracker)
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
  end
end