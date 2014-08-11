require 'test_helper'

class RatingOperationTest < MiniTest::Spec
  let (:thing) { Thing::Operation::Create[name: "Ruby"] }


  # valid create
  it do
    rating = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1
    ].model

    assert rating.id > 0
    assert rating.persisted?
  end

  # invalid create
  it do
    res, contract = Rating::Operation::Create.run(
      # thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1
    )

    res.must_equal false
    contract.errors.messages.must_equal(:thing=>["can't be blank"])
  end

  # delete
  it do
    rating = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1
    ].model

    Rating::Operation::Delete[id: rating.id].must_equal rating

    Rating.find(rating.id).deleted.must_equal 1
  end

  # undo
  it do
    rating = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1
    ].model

    Rating::Operation::Delete[id: rating.id].must_equal rating

    Rating::Operation::Undo[id: rating.id].must_equal rating
    Rating.find(rating.id).deleted.must_equal 0
  end
end