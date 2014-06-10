module Trailblazer
  module Operation
    class Create # DISCUSS: class?
      def call(domain, namespace, input, actions)
        twin = domain::Twin.new

        form = namespace.new(twin)
        yield form if block_given? # TODO: remove.

        # what about merging the Form::FLow stuff with Create?
        form.extend(Trailblazer::Operation::Flow) # FIXME: Only for fuckin Form.
        form.flow(input, actions)
      end
    end
  end
end