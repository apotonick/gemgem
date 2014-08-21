class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Operation::Create.contract(params) # Thing::Endpoint::New or Operation::Form::New
  end

  def create
    # TODO: this will get abstracted into Endpoint.
    if request.format == :html

      @form = Thing::Operation::Create.flow(params[:thing]) do |form|
        return redirect_to thing_path(form.model.id)
      end

      return render action: "new"

    elsif request.format == :json

      @form = Thing::Operation::Create::JSON.flow(request.body.string) do |form|
        return redirect_to thing_path(form.model.id)
      end

      raise # return render action: "new"

    end
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

  def edit
    @form = Thing::Operation::Update.contract(params)

    render action: :new
  end

  # has_cell :

  # TODO: test with and without image
  def show
    # TODO: let that do an Endpoint
    if request.format == :json

    end

    @thing = Thing.find(params[:id])

    @form = Rating::Operation::New.contract(params)
    # renders concept.
  end
  def form # TODO: this should happen in the cell-ajax.
    # DISCUSS: we could also think about hooking an Endpoint/Operation to a route that then renders the cell?
    # but, why? UI and API have different behaviour anyway.

    # use Endpoint::Create::"Form" here directly.
    @thing = Thing.find(params[:id])

    @form = Rating::Operation::Create.flow(params[:rating]) do |c|
     return redirect_to thing_path(@thing.id)
    end

    render action: :show
  end
end
