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

    module Form
      def self.included(base)
        bla=self
        base.class_eval do
          puts "base: #{base}"
          base.representer_class.options[:form_class] = Reform::Form

          require "reform/form/virtual_attributes" # TODO: where's this included?

          require 'reform/form/validate'
          include Reform::Form::Validate # extend Contract#validate with additional behaviour.
          require 'reform/form/sync'
          include Reform::Form::Sync
          require 'reform/form/save'
          include Reform::Form::Save

          require 'reform/form/multi_parameter_attributes'
          include Reform::Form::MultiParameterAttributes # TODO: make features dynamic.

          include Reform::Form::ActiveModel

          extend ModelName
        end



        # def aliased_model # DISCUSS: in Trailblazer, we don't need that.
      end

      module ModelName
          def model_name
            if model_options
              form_name = model_options.first.to_s.camelize
            else
              form_name = name.sub(/::Operation::Form$/, "") # Song::Form => "Song"
            end

            active_model_name_for(form_name)
          end
        end
    end
  end
end