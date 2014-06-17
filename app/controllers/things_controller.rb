class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Operation::Form.new(Thing::Twin.new) # Thing::Endpoint::New or Operation::Form::New
  end

  def create
    # Thing::Operation::Create.for(
    #   # form: valid: redirect, invalid: render
    #   # json: valid: render, invalid: render something else
    #   )

    # you can still do whatever you want in the controller, but the domain logic is encapsulated.
    Trailblazer::Endpoint::Create.new.call(self, params,
      # TODO: there's gonna be clever default settings a la Rails.
      {form: {
        success: lambda { |form| redirect_to thing_path(form.model.id) },
        invalid: lambda { |*| render action: "new" } # if this did actually call #new as in cells, we don't need the form object.
      },
      json: {
        success: lambda { |form| redirect_to thing_path(form.model.id) },
        # TODO: implement error handling.
        # invalid: lambda { |*| render action: "new" } # if this did actually call #new as in cells, we don't need the form object.
      }},
      Thing)
  end

  # has_cell :

  def show
    @thing = Thing::Twin.find(params[:id])
    rating  = Rating::Twin.new(thing: @thing) # Thing.ratings.build, or should that be handled by the form?
    @form   = Rating::Operation::Form.new(rating)

     # renders concept.
  end
  def form # TODO: this should happen in the cell-ajax.
    # DISCUSS: we could also think about hooking an Endpoint/Operation to a route that then renders the cell?
    # but, why? UI and API have different behaviour anyway.

    # use Endpoint::Create::"Form" here directly.
    @thing = Thing::Twin.find(params[:id])
    # rating  = Rating::Twin.new(thing: @thing)

    # should be Operation::Create::Form or Form.create
    Trailblazer::Operation::Create.new.call(Rating, Rating::Operation::Form, params[:rating],
      success: lambda { |*| redirect_to thing_path(@thing.id) },
      invalid: lambda { |*| render action: :show }) do |form|
        @form = form
      end
  end
end
