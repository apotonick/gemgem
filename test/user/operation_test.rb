require 'test_helper'

class UserOperationTest < MiniTest::Spec
  # valid create
  it do
    user = User::Operation::Create[
      email: "nick@trailblazerb.org",
    ]

    assert user.id > 0
    assert user.persisted?
  end

  # autocomplete
  it do
    User.delete_all # TODO: use database cleaner.

    user1 = User::Operation::Create[email: "nick@trailblazerb.org"]
    User::Operation::Create[email: "gonzo@web.de"]
    user3 = User::Operation::Create[email: "apotonick@gmail.com"]

    User::Operation::Search[term: "no"].must_equal []
    User::Operation::Search[term: "ick"].must_equal [
      {value: "#{user1.id}", label: "nick@trailblazerb.org"},
      {value: "#{user3.id}", label: "apotonick@gmail.com"}
    ]
  end

  # confirm account
  it do
    # op = Thing::Operation::Create[name: "Trb"]
    # rating = Rating::Operation::Create[comment: "Interesting!", weight: 1, thing: {id: op.model.id}, user: {email: "nick@trb.org"}].model

    require 'monban_extensions'
    user1 = User::Operation::Create[email: "nick@trailblazerb.org"]
    Monban::ConfirmLater[id: user1.id] # set User#confirmation_token. this is sent.
    user1.reload
    user1.confirmation_token.wont_equal nil

    Monban::IsConfirmationAllowed[id: user1.id, confirmation_token: "afsdfa"].must_equal false # in before_filter, policy.
    Monban::IsConfirmationAllowed[id: user1.id, confirmation_token: "abc123"].must_equal true

    Monban::Confirm[id: user1.id, password: "abc"] # call this from console!
    user1.reload
    assert user1.password_digest.size > 10

    # Monban::SignIn[]
  end
end

