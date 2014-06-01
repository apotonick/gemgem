require 'test_helper'

class RatingFormTest < MiniTest::Spec
# TODO: do with Operation:
  let(:thing) { Thing::Twin.new }
  before { thing.save }


  let (:rating) { Rating::Twin.new }

  let (:form) { Rating::Form.new(rating) }

  # new Rating.
  it {
    form.validate(comment: "Fantastic!", thing: {id: thing.id}).must_equal true
    form.save

    rating.thing.send(:model).must_equal thing.send(:model)
  } # and this is the API to "create" a Rating.

end