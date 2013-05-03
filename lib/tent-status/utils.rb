module TentStatus
  module Utils
    extend self

    module Hash
      extend self

      def dup(hash)
        transform_keys(hash, nil) { |k| k }.first
      end

      def slice(hash, *keys)
        keys.each_with_object(hash.class.new) { |k, new_hash|
          new_hash[k] = hash[k] if hash.has_key?(k)
        }
      end

      def slice!(hash, *keys)
        hash.replace(slice(hash, *keys))
      end

      def stringify_keys(hash)
        transform_keys(hash, :to_s).first
      end

      def stringify_keys!(hash)
        hash.replace(stringify_keys(hash))
      end

      def symbolize_keys(hash)
        transform_keys(hash, :to_sym).first
      end

      def symbolize_keys!(hash)
        hash.replace(symbolize_keys(hash))
      end

      def transform_keys(*items, method, &block)
        items.map do |item|
          case item
          when ::Hash
            item.inject(::Hash.new) do |new_hash, (k,v)|
              new_key = method ? k.send(method) : block.call(k)
              new_hash[new_key] = transform_keys(v, method, &block).first
              new_hash
            end
          when ::Array
            item.map { |i| transform_keys(i, method, &block).first }
          else
            item
          end
        end
      end
    end
  end
end
