module Trailblazer
  # new(twin).validate(params)[.save]
  class Contract < Reform::Contract # module?
    self.representer_class = Reform::Representer.for(:form_class => self)
    # Normally, a Reform::Contract only provides #validate().

    include Reform::Form::Validate

    module WithDeserialize
      def validate(json)
        #deserialize!(json)
         # this happens in Form#update!.


        super(json) # 1. populate, 2. validate.
      end

      def deserialize!(document)
        deserialize_for!(document)
      end
    end

    # TODO: should be Operation::Actions or something like that.
    class Actions < Hash
      def self.default
        hash = new
        hash.merge!(
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
    end

    module JSON
      def validate(json)
        #deserialize!(json)

        # TODO: use representable's parsing here.
        super(::JSON[json]) # 1. populate, 2. validate.
      end
    end
  end
end