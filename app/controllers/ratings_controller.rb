module Rating
  class Form < Reform::Form
    property :comment

    validates :comment, length: { in: 6..160 }
  end

  # require "disposable/facade"
  class Entity
    def initialize
      @facaded = Persistance.new
    end

    attr_accessor :comment

    def save
      facaded.update_attributes(comment: comment)
    end

    def persisted?
      facaded.persisted?
    end

    def to_key
      facaded.to_key
    end

  private
    attr_reader :facaded

    alias_method :persistance, :facaded
  end

  # TODO: one example with clean Persistance approach, one with facade for a legacy monolith.
  class Persistance < ActiveRecord::Base
    self.table_name=(:ratings)
  end
end




class RatingsController < ApplicationController
  def new
    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)
  end

  # DISCUSS: controller can only work with @form, not with @entity.
  def create
    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)


    if @form.validate(params[:rating_]) # TODO: make that "rating".
      @form.save
      @form.model.save

      return
    end

    render :action => :new
  end
end


