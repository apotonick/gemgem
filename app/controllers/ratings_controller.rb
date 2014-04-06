class RatingsController < ApplicationController
  def new
    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)
  end

  # DISCUSS: controller may only work with @form, not with @entity.
  def create
    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)

    if @form.validate(params[:rating]) # TODO: make that "rating".
      @form.save
      @form.model.save

      return
    end

    render :action => :new
  end

  def edit
    rating  = Rating::Entity.find(params[:id])
    @form   = Rating::Form.new(rating)

    render :action => :new
  end
end


