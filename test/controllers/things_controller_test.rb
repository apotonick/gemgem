require 'test_helper'

class ThingsControllerTest < ActionController::TestCase
  include Roar::Rails::TestCase
  tests ThingsController

  test "[json] POST /things" do
    post :create, {name: "Trailblazer"}.to_json, format: :json

    assert_response 302 # redirect, success
  end

  test "[form] POST /things" do
    post :create, {thing: {name: "Trailblazer"}}

    assert_response 302 # redirect, success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end

class RatingsControllerTest < ActionController::TestCase
  include Roar::Rails::TestCase
  tests RatingsController

  # test "[json] POST /things/1/ratings" do
  #   post :create, {comment: "Great!"}.to_json, format: :json

  #   assert_response 302 # redirect, success
  # end

  test "[form] POST /things/1/ratings" do
    post :create, {rating: {comment: "Great!"}, thing_id: 1}

    assert_response 302 # redirect, success
  end

  test "should get new" do
    get :new
    assert_response :success
  end
end




class ThingColonColonDomainlayerthatneedsANameTest < MiniTest::Spec
  subject { Thing::Twin.new }

  # Thing::Operation::Update::Hash # should we alias Update to Operation?

  before { @res = Thing::Operation::Hash.new(subject).
    # extend(Trailblazer::Operation::Flow). # TODO: do that per default.
    flow({"name" => "Chop Suey"}, {success: lambda {|*|}, invalid: lambda{|*|} }) }

  it { @res.must_equal true }
  it { subject.name.must_equal "Chop Suey" }
end
