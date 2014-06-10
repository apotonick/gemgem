module Trailblazer
  class Endpoint # in Trailblazer, controllers are Endpoints. they shouldn't be overridden as they do pretty generic shit.
    class Create

      def call(controller, params, endpoint_actions, domain=Thing) # FIXME: no dependency.
        is_json = controller.request.format == "application/json"
        namespace = (is_json ? domain::Operation::JSON : domain::Form)
        input = is_json ? controller.request.body.string : params[domain.to_s.underscore] #params[:thing]

        # FIXME: don't allow instance variables in controllers?
        Operation::Create.new.call(domain, namespace, input,  (endpoint_actions[is_json ? :json : :form])) do |form|
          controller.instance_variable_set(:@form, form) # TODO: remove.
        end
      end

    private
      def domain
        Thing
      end
    end
  end
end