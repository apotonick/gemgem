module Trailblazer
  class Endpoint # in Trailblazer, controllers are Endpoints. they shouldn't be overridden as they do pretty generic shit.
    class Create

      def call(controller, params, endpoint_actions, domain=Thing) # FIXME: no dependency.
        thing = domain::Twin.new

        # TODO: no json or http stuff in here!
        is_json = controller.request.format == "application/json"
        @form = (is_json ? domain::Operation::JSON : domain::Form).new(thing)
        input = is_json ? controller.request.body.string : params[:thing]

        # FIXME: don't allow instance variables in controllers?
        controller.instance_variable_set(:@form, @form)

        @form.extend(Trailblazer::Operation::Flow) # FIXME: Only for fuckin Form.
        @form.flow(input, endpoint_actions[is_json ? :json : :form])
      end

    private
      def domain
        Thing
      end
    end
  end
end