class ThingsController < ApplicationController
  respond_to :html, :json

  def index
    # pagination?
    # collection [..]
    @things = Thing.all.order("'created_at' DESC")
  end

  def new
    present Thing::Create
  end

  def create
    # TODO: this will get abstracted into Endpoint.
    # if request.format == :html
    operation = request.format == :json ? Thing::Create::JSON : Thing::Create
    _params    = request.format == :json ? params.merge(request_body: request.body.string) : params[:thing]

    _, op = operation.run(_params)

    @form = op.contract

    respond_with op
  end

  def edit
    @form = Thing::Update.contract(params)
    @crop = Thing::Crop.contract(params)

    render action: :new
  end

  def update
    @form = Thing::Update.run(params[:thing]) do |form|
        return redirect_to thing_path(form.model.id)
      end

      return render action: "new"
  end

  # has_cell :

  # TODO: test with and without image
  def show
    # params[:current_user] = current_user if signed_in?
    context = OpenStruct.new(current_user: current_user, id: params[:id]) # "Twin"
    #, to be passed into everything underneath this (cell -> operation).


    op = Thing::Show.new
    _, @thing = op.run(params)


    # TODO: let that do an Endpoint
    if request.format == "application/json"
      return respond_with op
    end

    # what if we had a Cell(contract/operation).show for html here? (to_html)

    # ok, who keeps signed-in user? op? twin?


    # this is UI, only, and could also be in a cell.
    @form = Rating::New.present(params)
  end

  def form # TODO: this should happen in the cell-ajax.
    # DISCUSS: we could also think about hooking an Endpoint/Operation to a route that then renders the cell?
    # but, why? UI and API have different behaviour anyway.
    op = Rating::Create.run(params) do |op|
      flash[:notice] = op.unconfirmed? ? "Check your email and confirm your account!" : "All good."
      return redirect_to thing_path(op.model.thing)
    end

    # this should be op.thing
    @thing = op.contract.thing # HTML logic.
    @form = op.contract

    render action: :show
  end

  def crop
    redirect_to thing_path(Thing::Crop[params[:thing]])
  end
end
