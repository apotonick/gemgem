module Trailblazer
  # new(twin).validate(params)[.save]
  class Contract < Reform::Contract
    def validate(json)
      deserialize!(json)
       # this happens in Form#update!.

      super()
    end

    def deserialize!(document)
      deserialize_for!(document)
    end

    module Hash
      # include Representable::Hash

      def deserialize_for!(hash)
        map = mapper
        map.send(:include,Representable::Hash) # TODO: Make that nicer.
        map.new(fields).from_hash(hash)
        puts "fields: #{fields.inspect}, #{hash.inspect}"
      end
    end

    module JSON
      # include Representable::JSON

      def deserialize_for!(hash)
        map = mapper
        map.send(:include,Representable::JSON) # TODO: Make that nicer.
        map.new(fields).from_json(hash)
      end
    end
  end
end