require 'test_helper'
require 'rating/cell'

class RatingCellTest < MiniTest::Spec
  let (:controller) { ThingsController.new.tap { |c| c.request = ActionDispatch::Request.new({}) } }

  it do
    thing = Thing::Operation::Create[name: "Apotomo"].model
    form = Rating::Operation::New.present(id: thing.id)

    html = Rating::Cell::Form.new(controller, form).show
    # puts html

    # TODO: move to Cell::Test
    page = Capybara::Node::Simple.new(html)
    page.has_selector?("form textarea").must_equal true
  end
end