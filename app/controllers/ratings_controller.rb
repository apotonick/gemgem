module Rateable
  class Entity# < Reform::Form # TODO: this is because I want the mapper functionality.
    def self.model_name
      ::ActiveModel::Name.new(self, nil, "Rateable") # Twin::ActiveModel should implement that. as a sustainable fix, we should simplify routing helpers.
    end
    #property :comment # TODO: use concept representer.

    def self.find(*args)
      new(Persistance.find(*args))
    end

    def initialize()
      # @facaded = nil
      # super(nil)
    end

    #attr_accessor :comment

    def save # implement that in Reform::AR.
      facaded.update_attributes(comment: comment)
    end

    def persisted?
      facaded.persisted?
    end

    # def to_key
    #   return [1]
    #   facaded.to_key
    # end

    # DISCUSS: this is used in simple_form_for [Rateable::Entity.new, @form] to compute nested URL. there must be a stupid respond_tp?(to_param) call in the URL helpers - remove that in Trailblazer.
    def to_param
      1
    end

  private
    attr_reader :facaded

    alias_method :persistance, :facaded
  end

  class Persistance < ActiveRecord::Base
    self.table_name = :rateables
  end
end


class RatingsController < ApplicationController
  def new
    rating  = Rating::Entity.new
    @form   = Rating::Form.new(rating)
  end

  # DISCUSS: controller may only work with @form, not with @entity.
  def create
    rating  = Rating::Entity.new # DISCUSS: we could also add Rateable here.
    @form   = Rating::Form.new(rating)

    form_params = params[:rating]
    # id: params[:rateable_id]
    form_params.merge!(
      # rateable: Rateable::Entity.find(params[:rateable_id])
      rateable: Rateable::Entity.new()
    ) # TODO: that's part of the populator (part of form) job?

    if @form.validate(params[:rating])
      @form.save
      @form.model.save

      return
    end

    # raise @form.errors.inspect
    render :action => :new
  end

  def edit
    rating  = Rating::Entity.find(params[:id])
    @form   = Rating::Form.new(rating)

    render :action => :new
  end

  def update
    rating  = Rating::Entity.find(params[:id])

    rating.rateable = Object.new


    @form   = Rating::Form.new(rating)

    if @form.validate(params[:rating])
      @form.save
      @form.model.save

      return redirect_to edit_rateable_rating_path(1, rating) # rating.url.edit
    end

    render :action => :new
  end
end


