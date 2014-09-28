require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @controller.extend(MonbanMockToBePushedIntoGem)
  end

  test "sign_in" do
    get :new
    assert_select "form"
  end
end
