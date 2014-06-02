class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Form.new(Thing::Twin.new)

  end

  def create
    local_params = nil


    @form = Thing::Form.new(Thing::Twin.new)
    if request.format == "application/json"
      @form.instance_eval do
        #mapper.extend(Roar::Representer::JSON)
        # have a representer that gets inherited in the form and use that representer here.
        def validate(json)
          super JSON[json]
        end
      end
      local_params = request.body.string
    end
    local_params ||= params[:thing]

    if @form.validate(local_params)
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
