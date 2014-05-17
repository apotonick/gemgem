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
end
