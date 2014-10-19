require 'test_helper'

class ThingsControllerTest < ActionController::TestCase
  # include Roar::Rails::TestCase
  # include Monban::Test::Helpers
  # Monban.test_mode!

  tests ThingsController

  setup do
    @controller.extend(MonbanMockToBePushedIntoGem)
  end

  let (:thing) { Thing::Create[name: "Cells"].model }

  test "GET /things/1" do
    get :show, id: thing.id
  end

  # new
  test "GET /things/new" do
    get :new
  end

  # JSON HAL tests.
  test "POST /things.json" do
    post :create, {name: "Trailblazer"}.to_json, format: :json
    thing = Thing.last # TODO: any better of finding this?

    response.body.must_equal "{\"name\":\"Trailblazer\",\"_embedded\":{\"authors\":[]},\"_links\":{\"self\":{\"href\":\"/things/#{thing.id}\"}}}"
  end

  test "POST /things.json with authors" do
    post :create, {name: "Trailblazer", authors: [{email: "nick@gmail.com"}]}.to_json, format: :json
    thing = Thing.last # TODO: any better of finding this?

    response.body.must_equal "{\"name\":\"Trailblazer\",\"_embedded\":{\"authors\":[{\"email\":\"nick@gmail.com\"}]},\"_links\":{\"self\":{\"href\":\"/things/#{thing.id}\"}}}"
  end

  test "POST /things.json with errors" do
    post :create, {thing: {name: ""}}.to_json, format: :json

    assert_response 422 # :unprocessable
  end

  test "GET /things/1.json" do
    get :show, id: thing.id, format: :json
    response.body.must_equal "{\"name\":\"Cells\",\"_embedded\":{\"authors\":[]},\"_links\":{\"self\":{\"href\":\"/things/#{thing.id}\"}}}"
  end


  # form tests.
  test "[form] POST /things" do
    post :create, {thing: {name: "Trailblazer"}}

    assert_redirected_to "/things/#{Thing.last.id}"
  end

  test "[form with errors] POST /things" do
    post :create, {thing: {name: ""}}

    assert_response :success
    assert_template :new
    assert_select "form"
  end

  # not signed in.
  test "should get new" do
    get :new
    assert_response :success
  end

end

# class RatingsControllerTest < ActionController::TestCase
#   include Roar::Rails::TestCase
#   tests RatingsController

#   # test "[json] POST /things/1/ratings" do
#   #   post :create, {comment: "Great!"}.to_json, format: :json

#   #   assert_response 302 # redirect, success
#   # end

#   test "[form] POST /things/1/ratings" do
#     post :create, {rating: {comment: "Great!"}, thing_id: 1}

#     assert_response 302 # redirect, success
#   end

#   test "should get new" do
#     get :new
#     assert_response :success
#   end
# end




# class ThingColonColonDomainlayerthatneedsANameTest < MiniTest::Spec
#   subject { Thing::Twin.new }

#   # Thing::Update::Hash # should we alias Update to Operation?

#   before { @res = Thing::Operation::Hash.new(subject).
#     # extend(Trailblazer::Operation::Flow). # TODO: do that per default.
#     flow({"name" => "Chop Suey"}, {success: lambda {|*|}, invalid: lambda{|*|} }) }

#   it { @res.must_equal true }
#   it { subject.name.must_equal "Chop Suey" }
# end
