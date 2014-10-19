require 'test_helper'

class RatingOperationTest < MiniTest::Spec
  let (:thing) { Thing::Create[thing: {name: "Ruby"}].model }


  # valid create
  it do
    rating = Rating::Create[
      rating: {
        # thing:   {id: thing.id},
        comment: "Fantastic!",
        weight:  1,
        user:    {email: "gerd@wurst.com"}
      },
      id: thing.id
    ].model

    assert rating.id > 0
    assert rating.persisted?
  end

  # invalid create
  it do
    res, operation = Rating::Create.run(
      rating: {
        # thing:   {id: thing.id},
        comment: "Fantastic!",
        weight:  1
      }
    )

    res.must_equal false
    operation.contract.errors.messages.must_equal(:thing=>["can't be blank"], :user=>["can't be blank"])
  end

  # create only works once with unregistered (new) user.
  it do
    op = Rating::Create[
      rating: {
        # thing:   {id: thing.id},
        comment: "Fantastic!",
        weight:  1,
        user:    {email: "gerd@wurst.com"}
      },
      id: thing.id
    ]

    op.unconfirmed?.must_equal true

    # second call is invalid!
    res, op = Rating::Create.run(
      rating: {
        # thing:   {id: thing.id},
        comment: "Absolutely amazing!",
        weight:  1,
        user:    {email: "gerd@wurst.com"}
      },
      id: thing.id
    )

    res.must_equal false
    op.contract.errors.to_s.must_equal "{:\"user.email\"=>[\"User needs to be confirmed first.\"]}"
  end
  # TODO: test registered user (unconfirmed? must always be true).with and without user: {}

  # signed in
  # valid create
  it "xxxx" do
    ryan = User::Create[email: "ryan@trb.com"]

    op = Rating::Create[
      rating: {
        # thing:   {id: thing.id},
        comment: "Fantastic!",
        weight:  1
      },
      id: thing.id,

      current_user: ryan # this should be in another hash, as this is Op-specific. what if the above hash was JSON string?
    ]

    op.unconfirmed?.must_equal nil
    op.model.user.must_equal ryan
  end
  # TODO: make sure peeps can't set user themselves.

  # signed in
  # invalid with user
  it "zzz" do
    ryan = User::Create[email: "ryan@trb.com"]

    res, op = Rating::Create.run( # see how we don't have to use Create::SignedIn?
      rating: {
        # thing:   {id: thing.id},
        comment: "Absolutely amazing!",
        weight:  1,
        user:    {id: -1}, # TODO: SHOULD BE EXISTING, WRONG USER!
        thing: {id: "bullshit"}
      },
      id: thing.id,
      current_user: ryan
    )

    # when implementing :readonly this works:
    # op.contract.thing.must_equal ryan
    res.must_equal true

    rating = op.model
    rating.user.must_equal ryan
    rating.comment.must_equal "Absolutely amazing!"
    rating.thing.must_equal thing

    # res.must_equal false

    # op.contract.errors.to_s.must_equal "{:\"user.email\"=>[\"User needs to be confirmed first.\"]}"

  end

  # delete
  it do
    rating = Rating::Create[
      rating: {
        # thing:   {id: thing.id},
        comment: "Fantastic!",
        weight:  1,
        user:    {email: "gerd@wurst.com"}
      },
      id: thing.id
    ].model

    Rating::Delete[id: rating.id].must_equal rating

    Rating.find(rating.id).deleted.must_equal 1
  end

  # undo
  it do
    rating = Rating::Create[
      rating: {
        # thing:   {id: thing.id},
        comment: "Fantastic!",
        weight:  1,
        user:    {email: "gerd@wurst.com"}
      },
      id: thing.id
    ].model

    Rating::Delete[id: rating.id].must_equal rating

    Rating::Undo[id: rating.id].must_equal rating
    Rating.find(rating.id).deleted.must_equal 0
  end
end