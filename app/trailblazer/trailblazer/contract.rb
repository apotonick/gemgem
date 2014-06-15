module Trailblazer
  # new(twin).validate(params)[.save]
  class Contract < Reform::Contract # module?
    def validate(json)
      deserialize!(json)
       # this happens in Form#update!.

      super()
    end

    def deserialize!(document)
      deserialize_for!(document)
    end


    # Implements a Flow with validating input and processing the result.
    module Flow
      require 'reform/form/sync'
      include Reform::Form::Sync
      require 'reform/form/save'
      include Reform::Form::Save

      def flow(input, actions)
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

    # module Form
    #   def self.included(base)
    #     base.representer_class = Reform::Representer.for(:form_class => base)
    #   end

    #   require "reform/form/virtual_attributes"

    #   require 'reform/form/validate'
    #   include Validate # extend Contract#validate with additional behaviour.
    #   require 'reform/form/sync'
    #   include Sync
    #   require 'reform/form/save'
    #   include Save

    #   require 'reform/form/multi_parameter_attributes'
    #   include MultiParameterAttributes # TODO: make features dynamic.

    #   # def aliased_model # DISCUSS: in Trailblazer, we don't need that.
    # end
  end
end