require 'test_helper'

class RatingsControllerTest < ActionController::TestCase
  # describe "/rateable/1/ratings/new" do
  # FIXME: i fuckin want describe!
    it "/rateable/1/ratings/new" do
      get :new, rateable_id: 1 # TODO: allow integration-like tests here with URL.

      assert_select "form" do
        assert_select "input[name='rating[comment]']", 1
      end
    end

    it "POST /rateable/1/ratings/" do
      post :create, rateable_id: 1, rating: {comment: "Grayt!!!"}

      # DISCUSS: what if we could test a controller without the controller, e.g. test the Reform form? something like validates?(...)
puts @response.body

      @response.body =~ /That was awesome!/

      Rating::Persistance.last.comment.must_equal "Grayt!!!"
      Rating::Persistance.last.rateable.id.must_equal 1
    end

  # end
end
