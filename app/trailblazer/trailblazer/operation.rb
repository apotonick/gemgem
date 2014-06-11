module Trailblazer
  module Operation # TODO: make a class. # TODO: should this be Operation::CRUD or something?
    require 'reform/form/sync'
    include Reform::Form::Sync
    require 'reform/form/save'
    include Reform::Form::Save
    # should this be something like ValidateSaveableContract (better name, of course)?

    def id
      model.id
    end


    module Flow # or is that an Operation?
      def flow(input, actions)
        if validate(input)
          save
          actions[:success].call(self)

          return self
        end

        actions[:invalid].call(self)
      end
    end
  end
end