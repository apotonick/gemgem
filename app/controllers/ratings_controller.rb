module Rating
  class Form < Reform::Form
    property :comment

    validates :comment, length: { in: 6..160 }
  end

  Entity = Struct.new(:comment)

  Entity.class_eval do
    def persisted?
      false
    end

    def to_key
      [:entity]
    end
  end
end




class RatingsController < ApplicationController
  def new

    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)
  end

  def create
    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)

    @form.validate(params[:rating_]) # TODO: make that "rating".

    render :action => :new
  end
end


