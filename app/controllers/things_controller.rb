class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Form.new(Thing::Twin.new)

  end

  def create
    @form = Thing::Form.new(Thing::Twin.new)

    if @form.validate(params[:thing])
      @form.save
      return render text: "All good, #{@form.model.inspect}"
    end

    return render action: 'new'
  end

  # has_cell :

  def show
    @thing = Thing::Twin.find(params[:id])



    rating  = Rating::Twin.new(thing: @thing)
    @form   = Rating::Form.new(rating)

     # renders concept.
  end
  def form # TODO: this should happen in the cell-ajax.
    @thing = Thing::Twin.find(params[:id])



    rating  = Rating::Twin.new(thing: @thing)
    @form   = Rating::Form.new(rating)

    if @form.validate(params[:rating])
      @form.save
      return redirect_to thing_path(@thing.id)
    end

    render action: :show
  end
end
