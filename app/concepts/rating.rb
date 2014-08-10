# ### Entity

# initialize
#   populate

# save/sync
#   update_attributes (save strategy)

# accessors

# why: to let the database layer be awesome but without business logic

# ActiveRecord/ActiveModel stuff is optional, so you can start working on a nested concept without having to implement the outer stuff (rateable)

# * make a validation where the thing is only valid when "owned"?

class Rating < ActiveRecord::Base
   # TODO: one example with clean Persistance approach, one with facade for a legacy monolith.
  belongs_to :thing


  module Form
    include Reform::Form::Module

    property :comment
    property :weight

    # i want rateable to be an actual object so i can verify it is a valid rateable_id!
    property :thing, populate_if_empty: lambda { |fragment, *| Thing.find(fragment[:id]) } do
    end # TODO: mark as typed. parse_strategy: :find_by_id would actually do what happens in the controller now.

    validates :comment, length: { in: 6..160 }
    validates :thing, presence: true
  end


  # think of this as Operation::Update
  module Operation
    class New < Trailblazer::Operation
      def run(params)
        thing = Thing.find(params[:id])
        rating = Rating.new(thing_id: thing.id)

        yield Create::Contract.new(rating)
      end
    end

    class Create < Trailblazer::Operation
      extend Flow

      class Contract < Reform::Form
        include Form

        model :rating

        validates :weight, presence: true

        # DISCUSS: this is presentation.
        def weight # only for presentation layer (UI).
          super or 1 # select Nice!
        end
      end


      def run(params)
        model = Rating.new

        validate(model, params) do |f|
          f.save
        end
      end
    end


    class Delete < Trailblazer::Operation
      def run(params)
        # note that we could also use a Form here.
        model = Rating.find(params[:id])

        model.update_column(:deleted, 1)

        super model
      end
    end
  end


  # name for "intermediate data copy can can sync back to twin"... copy, twin, shadow
    # property :rateable#, getter: lambda { |*|  } # TODO: mark an attribute as prototype (not implemented in persistance, yet)
    # TODO: make it simple to override def rateable, etc.
    # Entity doesn't know about ids, form doesn't know about associations?
end
