require 'test_helper'

class RatingTwinTest < MiniTest::Spec
  let (:rating) { Rating::Operation::Create[
    rating: {
      comment: "Fantastic!",
      weight:  1,
      user:    {email: "gerd@wurst.de"},
    },
    id: 1
    ].model

  }

  let (:twin) { Rating::Twin.new(rating) }

  # deleted?
  it { twin.deleted?.must_equal false }

  it {
    Rating::Operation::Delete[id: rating.id]
    rating.reload
    Rating::Twin.new(rating).deleted?.must_equal true
  }
end