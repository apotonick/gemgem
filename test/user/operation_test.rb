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
end

