class RatingsController < ApplicationController
  def new # DISCUSS: we don't need this anymore.
    # thing   =
    rating  = Rating::Twin.new
    @form   = Rating::Operation::Form.new(rating)
  end

  # DISCUSS: controller may only work with @form, not with @entity.
  def create
    params[:rating][:thing] = {:id => params[:thing_id]} # it is possible to set stuff before triggering Create.

    Trailblazer::Endpoint::Create.new.call(self, params,
      {form: {
        success: lambda { |form| redirect_to thing_path(form.model.thing.id) },
        invalid: lambda { |form| puts form.errors.messages.inspect; render action: "new" } # if this did actually call #new as in cells, we don't need the form object.
      }},
      Rating)
  end

  def edit
    rating  = Rating::Twin.find(params[:id])
    @form   = Rating::Operation::Form.new(rating)

    render :action => :new
  end

  def update
    rating  = Rating::Twin.find(params[:id])

    raise rating.rateable.inspect
    # rating.rateable = Object.new


    @form   = Rating::Operation::Form.new(rating)

    if @form.validate(params[:rating])
      @form.save
      @form.model.save

      return redirect_to edit_rateable_rating_path(1, rating) # rating.url.edit
    end

    render :action => :new
  end

  def show
    @rating = Rating::Twin.find(params[:id])
  end

  def destroy
    rating = Rating::Operation::Delete[id: params[:id]]
    redirect_to thing_path(rating.thing.id)
  end

   def undo
    Rating::Operation::Undo.run(id: params[:id]) do |rating|
      redirect_to thing_path(rating.thing.id)
    end
  end
end


