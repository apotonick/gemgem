# ### Entity

# initialize
#   populate

# save/sync
#   update_attributes (save strategy)

# accessors

module Rating
  class Form < Reform::Form
    property :comment

    validates :comment, length: { in: 6..160 }
  end

  # name for "intermediate data copy can can sync back to twin"... copy, twin, shadow
  # require "representable/twin"
  class Entity < Reform::Form # TODO: this is because I want the mapper functionality.
    property :comment # TODO: use concept representer.

    def self.find(*args)
      new(Persistance.find(*args))
    end

    def initialize(facaded=Persistance.new)
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
  end
end
