require 'test_helper'

describe "OP::Create" do
  subject { Rating::Twin.new }

  # Thing::Operation::Update::Hash # should we alias Update to Operation?


  # Rating::Operation::Create::Hash.new.call == Fucktory
  let (:operation) { Rating::Operation::Hash.new(subject) }
  let (:flow) { @res = operation.flow(params) }


  describe "valid" do
    let (:params) { {"comment" => "Amazing!", "thing" => {:id => 1}} }

    before { flow }

    it { @res.must_equal true }
    it { subject.comment.must_equal "Amazing!" }
  end


  describe "invalid" do
    let (:params) { {"comment" => "Amazing!"} }

    before { assert_raises( RuntimeError) { flow } }

    it { @res.must_equal nil }
    it { subject.comment.must_equal nil }
    it { operation.comment.must_equal "Amazing!" }
    it { operation.errors.messages.must_equal({:thing=>["can't be blank"]}) }
  end
end

class RatingOperationUpdateTest < MiniTest::Spec
  let (:twin) { Rating::Twin.new } # TODO: return from flow.
  let (:rating) { Rating::Operation::Hash.new(twin).flow({comment: "Amazing!", thing: {id: 1}}) }

  it "what" do
    rating
    puts twin.inspect

    Rating::Operation::Hash.new(twin).flow({comment: "Amazing!!"
      # , thing: {id: 1}
    })

    twin.comment.must_equal "Amazing!!"
    twin.thing.id.must_equal 1
  end
end