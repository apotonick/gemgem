require 'test_helper'

class UserTwinTest < MiniTest::Spec
  let (:user) { User::Create[email: "nick@trailblazerb.org"] }
  let (:twin) { User::Twin.new(user) }

  it { twin.avatar.must_equal "/images/avatar.png" }
  it { twin.thumb.must_equal "/images/avatar-thumb.png" }

  describe "#avatar" do

  end
end