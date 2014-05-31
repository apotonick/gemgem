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

    return render action: 'new' # renders concept.
  end

  def show
    @thing = Thing::Twin.find(params[:id])



    rating  = Rating::Twin.new(thing: @thing)
    @form   = Rating::Form.new(rating)
  end
end
