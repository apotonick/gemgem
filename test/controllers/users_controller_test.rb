require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @controller.extend(MonbanMockToBePushedIntoGem)
  end

  # test "sign_in" do
  #   get :sign_in
  # end

  let (:user) { User::Operation::Create[{email: "richy@trb.org"}] }

  # SHOW
  test "/users/1" do
    get :show, id: user.id

    response.body.must_match /trb.org/
  end

  # SHOW.json, no ratings
  test "/users/1.json" do
    get :show, id: user.id, format: :json

    response.body.must_equal "{\"email\":\"richy@trb.org\",\"links\":[{\"rel\":\"self\",\"href\":\"http://users/#{user.id}\"}]}"
  end

  # SHOW.json, with ratings
  test "/users/1.json" do
    thing = Thing::Operation::Create[name: "Monban"].model
    Rating::Operation::Create::SignedIn[rating: {comment: "Great!", weight: 1}, id: thing.id, current_user: user]

    get :show, id: user.id, format: :json

    response.body.must_equal "{\"email\":\"richy@trb.org\",\"links\":[{\"rel\":\"self\",\"href\":\"http://users/#{user.id}\"}],\"ratings\":[{\"comment\":\"Great!\",\"links\":[{\"rel\":\"self\",\"href\":\"http://ratings/172\"}]}]}"
  end


  # EDIT
  test "/users/1/edit" do
   # visit "/users/#{user.id}"
   get :edit, id: user.id

    assert_response :success
    # assert page.has_css? "#user_email"
    assert_select "#user_email[value='#{user.email}']"
  end

  # POST update
  test "/users/1/update" do
   # visit "/users/#{user.id}"
   post :update, id: user.id, user: {name: "Ryan"}

    assert_response :success
    # assert page.has_css? "#user_email"
    assert_select "#user_name[value='Ryan']"
  end

  # POST update.json
  test "/users/1/update.json" do
    post :update, {name: "Ryan"}.to_json, id: user.id, format: :json

    # TODO: test respond_with
    user.reload
    user.name.must_equal "Ryan"

    response.body.must_equal "{\"name\":\"Ryan\",\"email\":\"richy@trb.org\",\"links\":[{\"rel\":\"self\",\"href\":\"http://users/#{user.id}\"}]}"
  end
end
