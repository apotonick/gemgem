class UsersController < ApplicationController
  respond_to :json

  def search
    respond_with User::Operation::Search[params]
    # render json: [{"label"=>"mylabel","value"=>"myvalue"}]
  end

  before_filter :is_confirm_allowed?, only: :confirm
  def confirm
    @form = User::Operation::Confirm.contract(params)
  end

private
  def is_confirm_allowed?
    require 'monban_extensions'
    raise unless Monban::IsConfirmationAllowed[params]
  end
end
