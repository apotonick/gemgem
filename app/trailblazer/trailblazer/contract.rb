module Trailblazer
  # new(twin).validate(params)[.save]
  class Contract < Reform::Contract # module?
    # Normally, a Reform::Contract only provides #validate().
    module WithDeserialize
      def validate(json)
        deserialize!(json)
         # this happens in Form#update!.

        super()
      end

      def deserialize!(document)
        deserialize_for!(document)
      end
    end

    # TODO: should be Operation::Actions or something like that.
    class Actions < Hash
      def default
        new(
          :success => lambda { |form| },
          :invalid => lambda { |form| raise form.errors.messages.inspect }
        )
      end
    end


    # Implements a Flow with validating input and processing the result.
    module Flow # should be Flow::Save
      require 'reform/form/sync'
      include Reform::Form::Sync
      require 'reform/form/save'
      include Reform::Form::Save

      def flow(input, actions=Actions.default)
        if result = validate(input)
          save
          actions[:success].call(self) # handle that in Operation::Create?

          return result
        end

        actions[:invalid].call(self) # handle that in Operation::Create?
      end
    end

    # DISCUSS: currently, i don't see why you would use a Contract without Flow, so i always include it.
    include Flow


    module Hash
      include WithDeserialize
      # include Representable::Hash

      def deserialize_for!(hash)
        map = mapper
        map.send(:include,Representable::Hash) # TODO: Make that nicer.
        map.new(fields).from_hash(hash)
        puts "fields: #{fields.inspect}, #{hash.inspect}"
      end
    end

    module JSON
      include WithDeserialize
      # include Representable::JSON

      def deserialize_for!(hash)
        map = mapper
        map.send(:include,Representable::JSON) # TODO: Make that nicer.
        map.new(fields).from_json(hash)
      end
    end
  end
end