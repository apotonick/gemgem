require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @controller.extend(MonbanMockToBePushedIntoGem)
  end

  # test "sign_in" do
  #   get :sign_in
  # end

  # EDIT
  let (:user) { User::Operation::Create[{email: "richy@trb.org"}] }

  test "/users/1/edit" do
   # visit "/users/#{user.id}"
   get :edit, id: user.id

    assert_response :success
    # assert page.has_css? "#user_email"
    assert_select "#user_email[value='#{user.email}']"
  end

  test "/users/1/update" do
   # visit "/users/#{user.id}"
   post :update, id: user.id, user: {name: "Ryan"}

    assert_response :success
    # assert page.has_css? "#user_email"
    assert_select "#user_name[value='Ryan']"
  end
end
