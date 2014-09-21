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

  include Monban::ControllerHelpers
  # TODO: pass on confirmation_token for locking out idiots.
  def confirm_save
    op=User::Operation::Confirm.run(params) do |op|
      # this is controller-specific. i don't want that in operation (imagine that on the console).
      sign_in(op.model) # from Monban::ControllerHelpers.
      flash[:notice] = "Yay, you're signed in, buddy!"
      return redirect_to things_path
    end

    @form = op.contract
    render action: :confirm
    # raise op.contract.errors.inspect
  end

private
  def is_confirm_allowed?
    # TODO: raise 401 Unauthorized / show decent "want another token?" page.
    raise unless Monban::IsConfirmationAllowed[params]
  end
end
