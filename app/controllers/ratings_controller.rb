


class RatingsController < ApplicationController
  def new
    # thing   =
    rating  = Rating::Twin.new
    @form   = Rating::Form.new(rating)
  end

  # DISCUSS: controller may only work with @form, not with @entity.
  def create
    rating  = Rating::Twin.new # DISCUSS: we could also add Rateable here.
    @form   = Rating::Form.new(rating)

    form_params = params[:rating]
    form_params[:thing] = {id: params[:thing_id]}

    if @form.validate(params[:rating])
      @form.save
      # @form.model.save

      return redirect_to thing_url(params[:thing_id])
    end

    # raise @form.errors.inspect
    render :action => :new
  end

  def edit
    rating  = Rating::Twin.find(params[:id])
    @form   = Rating::Form.new(rating)

    render :action => :new
  end

  def update
    rating  = Rating::Twin.find(params[:id])

    raise rating.rateable.inspect
    # rating.rateable = Object.new


    @form   = Rating::Form.new(rating)

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
end


