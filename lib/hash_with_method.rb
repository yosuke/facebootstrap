class HashWithMethod < Hash
  def self.from(hash)
    instance = self.new
    hash.symbolize_keys.each do |key, value|
      case value
      when Hash
        value = self.from(value)
      when Array
        value = value.map { |v| from_any(v) }
      end
      instance[key] = value
      instance.send :define_refer_method, key
    end
    instance
  end
  private
  def self.from_any(object)
    return object unless object.is_a? Hash
    self.from object
  end
  def define_refer_method(key)
    self.class.send :define_method, key do
      self[key]
    end
  end
end
