require 'test_helper'

class RatingPopulator < Representable::Decorator
  include Representable::Hash
  include Representable::Hash::AllowSymbols

  property :comment
  property :thing, class: OpenStruct do
    property :id
  end
end

class RatingValidator < Reform::Contract
  property :comment
  property :thing, class: OpenStruct do
    property :id
    property :cool

    validates :cool, presence: true
  end

  validates :comment, presence: true
  validates :thing, presence: true
end

class RumspielTest < MiniTest::Spec
  it "what" do

    # populate:
    rating = OpenStruct.new

    RatingPopulator.new(rating).from_hash(comment: "Wird", thing: {id: 1})

    puts rating.inspect


    # validate:
    validator = RatingValidator.new(rating)
    puts validator.validate

    puts validator.errors.messages.inspect

  end
end