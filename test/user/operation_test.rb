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
      {value: "id:#{user1.id}", label: "nick@trailblazerb.org"},
      {value: "id:#{user3.id}", label: "apotonick@gmail.com"}
    ]
  end
end

