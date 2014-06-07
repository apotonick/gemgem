module Trailblazer
  module Operation # TODO: make a class. # TODO: should this be Operation::CRUD or something?
    def validate(json)
      deserialize(json)
       # this happens in Form#update!.

      super()
    end

    require 'reform/form/sync'
    include Reform::Form::Sync
    require 'reform/form/save'
    include Reform::Form::Save

    def id
      model.id
    end

    def remove_me
      'new'
    end


    module Flow # or is that an Operation?
      def flow(controller, input)
        if validate(input)
          save
          controller.redirect_to controller.thing_path(id)
          return self
        end

        controller.render action: remove_me
      end
    end
  end
end