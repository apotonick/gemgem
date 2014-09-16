class ThingsController < ApplicationController
  #include Roar::Rails::ControllerAdditions
  #represents :json, :entity => Thing::Representer
  respond_to :html, :json

  def index
    # pagination?
    # collection [..]
    @things = Thing.all.order("'created_at' DESC")
  end

  def new
    @form = Thing::Operation::Create.contract(params) # Thing::Endpoint::New or Operation::Form::New
  end

  def create
    # TODO: this will get abstracted into Endpoint.
    # if request.format == :html
    operation = request.format == :json ? Thing::Operation::Create::JSON : Thing::Operation::Create
    _params    = request.format == :json ? params.merge(request_body: request.body.string) : params[:thing]

    _, op = operation.run(_params)

    @form = op.contract

    respond_with op
  end

  def edit
    @form = Thing::Operation::Update.contract(params)
    @crop = Thing::Operation::Crop.contract(params)

    render action: :new
  end

  def update
    @form = Thing::Operation::Update.run(params[:thing]) do |form|
        return redirect_to thing_path(form.model.id)
      end

      return render action: "new"
  end

  # has_cell :

  # TODO: test with and without image
  def show
    op = Thing::Operation::Show.new
    _, @thing = op.run(params)


    # TODO: let that do an Endpoint
    if request.format == "application/json"
      return respond_with op
    end

    # what if we had a Cell(contract/operation).show for html here? (to_html)

    # this is UI, only, and could also be in a cell.
    @form = Rating::Operation::New.contract(params)
  end

  def form # TODO: this should happen in the cell-ajax.
    # DISCUSS: we could also think about hooking an Endpoint/Operation to a route that then renders the cell?
    # but, why? UI and API have different behaviour anyway.
    op = Rating::Operation::Create.run(params[:rating]) do |op|
      flash[:notice] = op.unconfirmed? ? "Check your email and confirm your account!" : "All good."
      return redirect_to thing_path(op.model.thing)
    end

    # this should be op.thing
    @thing = op.contract.thing.model # HTML logic.
    @form = op.contract

    render action: :show
  end

  def crop
    redirect_to thing_path(Thing::Operation::Crop[params[:thing]])
  end
end
