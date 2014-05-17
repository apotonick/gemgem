


class RatingsController < ApplicationController
  def new
    rating  = Rating::Twin.new
    @form   = Rating::Form.new(rating)
  end

  # DISCUSS: controller may only work with @form, not with @entity.
  def create
    rating  = Rating::Twin.new # DISCUSS: we could also add Rateable here.
    @form   = Rating::Form.new(rating)

    form_params = params[:rating]
    # id: params[:rateable_id]
    # form_params.merge!(
    #   # rateable: Rateable::Entity.find(params[:rateable_id])
    #   rateable: Rateable::Entity.new()
    # ) # TODO: that's part of the populator (part of form) job?
    form_params[:rateable] = {id: params[:rateable_id]}

    if @form.validate(params[:rating])
      @form.save
      #@form.model.save

      raise rating.model.inspect
      return
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
end


