require 'test_helper'

Rails.backtrace_cleaner.remove_silencers!

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
