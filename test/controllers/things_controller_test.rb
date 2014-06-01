require 'test_helper'

Rails.backtrace_cleaner.remove_silencers!

class ThingsControllerTest < ActionController::TestCase
  include Roar::Rails::TestCase

  test "POST /things" do
    post :create, {title: "Trailblazer"}.to_json, format: :json

    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end
