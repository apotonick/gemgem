require 'test_helper'

class RatingFormTest < MiniTest::Spec
# TODO: do with Operation:
  let(:thing) { Thing::Twin.new }
  before { thing.save }


  let (:rating) { Rating::Twin.new }

  let (:form) { Rating::Form.new(rating) }

  # new Rating.
  it {
    form.validate(comment: "Fantastic!", thing: {id: thing.id}).must_equal true  # and this is the API to "create" a Rating.
    form.save

    rating.thing.send(:model).must_equal thing.send(:model)
  }

end

module Rating::Operation
  class Create
    def initialize
      # @rating = twin
    end

    def call(params)
      @rating = Rating::Twin.new
      form = Rating::Form.new(@rating)
      form.validate(params)
      form.save

      @rating
    end
  end
end