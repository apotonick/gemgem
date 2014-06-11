# ### Entity

# initialize
#   populate

# save/sync
#   update_attributes (save strategy)

# accessors

# why: to let the database layer be awesome but without business logic

# ActiveRecord/ActiveModel stuff is optional, so you can start working on a nested concept without having to implement the outer stuff (rateable)

module Rating
   # TODO: one example with clean Persistance approach, one with facade for a legacy monolith.
  class Persistence < ActiveRecord::Base
    self.table_name=(:ratings)

    belongs_to :thing, class_name: Thing::Persistence
  end

  # module Schema
  #   include Representable

  #   property :comment
  #   property :thing, extend: Module.new
  # end

  class Contract < Reform::Contract
    property :comment

    # i want rateable to be an actual object so i can verify it is a valid rateable_id!
    property :thing, populate_if_empty: lambda { |fragment, *| Thing::Twin.find(fragment[:id]) } do
    end # TODO: mark as typed. parse_strategy: :find_by_id would actually do what happens in the controller now.

    validates :comment, length: { in: 6..160 }
    validates :thing, presence: true
  end

  require 'representable/decorator'
  module Schema
    include Representable
    @representable_attrs = Contract.representer_class.representable_attrs
  end

  class Representer < Representable::Decorator
    @representable_attrs = Contract.representer_class.representable_attrs
  end



  # this is the Create form, it finds the Rateable.
  # TODO: make this work with an HTTP API endpoint where the form _is_ the representer as discussed with @timoschilling.
  class Form < Reform::Form
    property :comment
    property :weight, presentation_accessors: true


    # i want rateable to be an actual object so i can verify it is a valid rateable_id!
    property :thing, populate_if_empty: lambda { |fragment, *| Thing::Twin.find(fragment[:id]) } do
    end # TODO: mark as typed. parse_strategy: :find_by_id would actually do what happens in the controller now.

    validates :comment, length: { in: 6..160 }
    validates :thing, presence: true

    validates :weight, presence: true

    def weight # only for presentation layer (UI).
      super or 1 # select Nice!
    end
  end

  class Operation < Trailblazer::Contract # "Saveable"
    include Trailblazer::Operation
    # include Rating::Representer
    include Representable
    include Schema

    def id
      model.thing.id # FIXME.
    end

    class JSON < self
      include Trailblazer::Contract::JSON
    end

    class Hash < self
      include Trailblazer::Contract::Hash
    end
  end

  class Twin < Disposable::Twin
    # We have to define all fields we wanna expose.
    property :id

    property :comment
    property :weight

    property :created_at
    property :thing, twin: ->{Thing::Twin}

    model Persistence

    def persisted?
      model.persisted?
    end

    def to_key
      model.to_key
    end

    def to_param
      id
    end
  end

  # name for "intermediate data copy can can sync back to twin"... copy, twin, shadow
    # property :rateable#, getter: lambda { |*|  } # TODO: mark an attribute as prototype (not implemented in persistance, yet)
    # TODO: make it simple to override def rateable, etc.
    # Entity doesn't know about ids, form doesn't know about associations?
end
