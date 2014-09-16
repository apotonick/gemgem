require 'test_helper'

class RatingOperationTest < MiniTest::Spec
  let (:thing) { Thing::Operation::Create[name: "Ruby"].model }


  # valid create
  it do
    rating = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1,
      user:    {email: "gerd@wurst.com"}
    ].model

    assert rating.id > 0
    assert rating.persisted?
  end

  # invalid create
  it do
    res, operation = Rating::Operation::Create.run(
      # thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1
    )

    res.must_equal false
    operation.contract.errors.messages.must_equal(:thing=>["can't be blank"], :user=>["can't be blank"])
  end

  # create only works once with unregistered (new) user.
  it do
    op = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1,
      user:    {email: "gerd@wurst.com"}
    ]

    op.unconfirmed?.must_equal true

    # second call is invalid!
    res, op = Rating::Operation::Create.run(
      thing:   {id: thing.id},
      comment: "Absolutely amazing!",
      weight:  1,
      user:    {email: "gerd@wurst.com"}
    )

    res.must_equal false
    op.contract.errors.to_s.must_equal "{:\"user.email\"=>[\"has already been taken\"]}"
  end
  # TODO: test registered user (unconfirmed? must always be true).

  # delete
  it do
    rating = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1,
      user:    {email: "gerd@wurst.com"}
    ].model

    Rating::Operation::Delete[id: rating.id].must_equal rating

    Rating.find(rating.id).deleted.must_equal 1
  end

  # undo
  it do
    rating = Rating::Operation::Create[
      thing:   {id: thing.id},
      comment: "Fantastic!",
      weight:  1,
      user:    {email: "gerd@wurst.com"}
    ].model

    Rating::Operation::Delete[id: rating.id].must_equal rating

    Rating::Operation::Undo[id: rating.id].must_equal rating
    Rating.find(rating.id).deleted.must_equal 0
  end
end