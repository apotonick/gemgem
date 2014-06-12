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

class ThingColonColonDomainlayerthatneedsAName < MiniTest::Spec
  subject { Thing::Twin.new }

  before { @res = Thing::Operation::Hash.new(subject).
    extend(Trailblazer::Operation::Flow). # TODO: do that per default.
    flow({"name" => "Chop Suey"}, {success: lambda {|*|}, invalid: lambda{|*|} }) }

  it { @res.must_equal true }
  it { subject.name.must_equal "Chop Suey" }
end
