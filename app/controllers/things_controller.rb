class ThingsController < ApplicationController
  respond_to :html, :json
  include Trailblazer::Operation::Controller

  def index
    # pagination?
    # collection [..]
    @things = Thing.all.order("'created_at' DESC")
  end

  def new
    present Thing::Create
  end

  def create
    run Thing::Create do |op|
      redirect_to op.model
    end.else do |op|
      render action: :new
    end
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
    present Thing::Show do
      @form = Rating::New.present(params)
      @thing = @model
    end
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
