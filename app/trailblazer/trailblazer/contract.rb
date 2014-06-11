module Trailblazer
  # new(twin).validate(params).save
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
      include Representable::Hash

      def deserialize_for!(hash)
        from_hash(hash)
      end
    end

    module JSON
      include Representable::JSON

      def deserialize_for!(hash)
        from_json(hash)
      end
    end
  end
end