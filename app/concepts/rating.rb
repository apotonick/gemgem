# ### Entity

# initialize
#   populate

# save/sync
#   update_attributes (save strategy)

# accessors

# why: to let the database layer be awesome but without business logic

# ActiveRecord/ActiveModel stuff is optional, so you can start working on a nested concept without having to implement the outer stuff (rateable)

module Rating
  class Form < Reform::Form
    property :comment
    property :rateable # TODO: mark as typed. parse_strategy: :find_by_id would actually do what happens in the controller now.

    validates :comment, length: { in: 6..160 }
    validates :rateable, presence: true
  end

  # name for "intermediate data copy can can sync back to twin"... copy, twin, shadow
  # require "representable/twin"
  class Entity < Reform::Form # TODO: this is because I want the mapper functionality.
    property :comment # TODO: use concept representer.
    property :rateable#, getter: lambda { |*|  } # TODO: mark an attribute as prototype (not implemented in persistance, yet)
    # TODO: make it simple to override def rateable, etc.

    # Entity doesn't know about ids, form doesn't know about associations?

    def self.find(*args)
      new(Persistance.find(*args))
    end

    def initialize(facaded=Persistance.new) # Persistance.new or OpenStruct.new
      @facaded = facaded
      super
    end

    #attr_accessor :comment

    def save # implement that in Reform::AR.
      facaded.update_attributes(comment: comment)
    end

    def persisted?
      facaded.persisted?
    end

    def to_key
      facaded.to_key
    end

  private
    attr_reader :facaded

    alias_method :persistance, :facaded
  end

  # TODO: one example with clean Persistance approach, one with facade for a legacy monolith.
  class Persistance < ActiveRecord::Base
    self.table_name=(:ratings)

    belongs_to :rateable
  end
end
