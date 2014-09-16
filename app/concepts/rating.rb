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
  belongs_to :user


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
    class Create < Trailblazer::Operation
     class Contract < Reform::Form
        include Form

        model :rating

        validates :weight, presence: true

        # DISCUSS: this is presentation.
        def weight # only for presentation layer (UI).
          super or 1 # select Nice!
        end


        property :user, populate_if_empty: User do # we could create the User in the Operation#process?
          # property :name
          property :email

          validates :email, presence: true
          # validates :email, email: true
          #validates_uniqueness_of :email # this assures the new user is new and not an existing one.

          # this should definitely NOT sit in the model.
          validate :confirmed_or_new_and_unique?

          def confirmed_or_new_and_unique?
            existing = User.find_by_email(email)
            return if existing.nil?
            return if existing and existing.password_digest
            errors.add(:email, "User needs to be confirmed first.")
          end
        end
        validates :user, presence: true
      end

      def setup!(params)
        @model = Rating.new
      end
      attr_reader :model

      def process(params)
        # create user here?
        validate(params, model) do |f|
          @unconfirmed = !f.user.model.persisted? # if we create the user here, we don't need this logic?
          f.save
        end
      end

      # i hereby break the statelessness!
      def unconfirmed?
        @unconfirmed
      end
    end


    class New < Create
      def setup!(params)
        thing  = Thing.find(params[:id])
        @model = Rating.new(thing_id: thing.id)
        @model.build_user # DISCUSS: where does this go?
      end
    end


    class Delete < Trailblazer::Operation
      def process(params)
        model = Rating.find(params[:id])
        model.update_column(:deleted, 1)
        model
      end
    end


    class Undo < Trailblazer::Operation
      def process(params)
        # note that we could also use a Form here.
        model = Rating.find(params[:id])
        model.update_column(:deleted, 0)
        model
      end
    end
  end


  class Twin < Disposable::Twin
    def deleted?
      model.deleted == 1
    end
  end


  # name for "intermediate data copy can can sync back to twin"... copy, twin, shadow
    # property :rateable#, getter: lambda { |*|  } # TODO: mark an attribute as prototype (not implemented in persistance, yet)
    # TODO: make it simple to override def rateable, etc.
    # Entity doesn't know about ids, form doesn't know about associations?
end
