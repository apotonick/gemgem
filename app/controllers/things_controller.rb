class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Form.new(Thing::Twin.new)

  end

  class Contractor < Thing::Contract
    # 1. in initialize, the twin data populates the contract
    #    that is correct as the twin might be an existing, already populated object
    #    and the incoming data is only a sub-set.
    # def initialize(twin)
    #   @twin = twin
    #   @contract= Thing::Contract.new(@twin) # Setup
    # end

    def validate(json)
      Thing::Representer.new(self).from_json(json) # this happens in Form#update!.

      # @contract.validate # super
      super()
    end

    require 'reform/form/sync'
    include Reform::Form::Sync
    require 'reform/form/save'
    include Reform::Form::Save

    def id
      model.id
    end
  end

  def create
    is_json = request.format == "application/json"

    thing = Thing::Twin.new

    @form = (is_json ? Contractor : Thing::Form).new(thing)
    input = is_json ? request.body.string : params[:thing]


    if @form.validate(input)
      @form.save
      return redirect_to thing_path(@form.id)
    end

    return render action: 'new'
  end

  # has_cell :

  def show
    @thing = Thing::Twin.find(params[:id])
    rating  = Rating::Twin.new(thing: @thing) # Thing.ratings.build, or should that be handled by the form?
    @form   = Rating::Form.new(rating)

     # renders concept.
  end
  def form # TODO: this should happen in the cell-ajax.
    # DISCUSS: we could also think about hooking an Operation to a route that then renders the cell?
    # but, why? UI and API have different behaviour anyway.

    @thing = Thing::Twin.find(params[:id])
    # rating  = Rating::Twin.new(thing: @thing)

    # everything below the line here is done in Rating::Operation::Create
    rating  = Rating::Twin.new
    @form   = Rating::Form.new(rating)

    if @form.validate(params[:rating])
      @form.save
      return redirect_to thing_path(@thing.id)
    end

    render action: :show
  end
end
