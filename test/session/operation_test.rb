require 'test_helper'

class SessionOperationTest < MiniTest::Spec
  # Signin#present
  it { Session::Signin.present({}).must_be_kind_of Reform::Form }

  # Signin#run, user not existent.
  it do
    res, op = Session::Signin.run({email: "ryan@trb.com", password: "the wrong one"})
    res.must_equal false
    # TODO: test that warden empty
  end

  # Signin#run, valid
  it do
    user= User::Create[email: "ryan@trb.com"]
    User::Confirm[id: user.id, user: {password: "the right", password_confirmation: "the right"}] # TODO: allow that in one step.

    res, op = Session::Signin.run({email: "ryan@trb.com", password: "the right"})
    res.must_equal true
  end
end