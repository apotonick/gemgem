class UsersController < ApplicationController
  respond_to :json#, :html
  include Trailblazer::Operation::Controller

  def search
    respond_with User::Operation::Search[params]
    # render json: [{"label"=>"mylabel","value"=>"myvalue"}]
  end

  def show
    present User::Show
  end



  def edit
    # TODO: authorization, is that me trying to update?

    present User::Update do |op| # this runs op."contract" but returns the op. Op#init ?
      # this is absolutely ok here - this is presentation logic only for HTML.
      # i could also use User::Edit but i don't need it presently.
      # @form = op.contract
    end
  end

  def update
    # ideally,we only need html config here. if not, pass format into block?!
    # json etc should be handled in responder per default (api behaviour).
    run User::Update do |op|
      # html only.
      flash[:notice] = "Updated."
      render action: :edit # DISCUSS: should that be done automatically IN #run?
    end.else do
      render action: :edit # invalid.
    end
  end

  # maybe that should be abstracted in a higher Operation?
  before_filter :is_confirm_allowed?, only: :confirm
  def confirm
    @form = User::Operation::Confirm.contract(params)
  end

  # TODO: pass on confirmation_token for locking out idiots.
  def confirm_save
    op=User::Operation::Confirm.run(params) do |op|
      # this is controller-specific. i don't want that in operation (imagine that on the console).
      sign_in(op.contract.model) # from Monban::ControllerHelpers.
      flash[:notice] = "Yay, you're signed in, buddy!"
      return redirect_to things_path
    end

    @form = op.contract
    render action: :confirm # DISCUSS: rendering should work on Op?
  end

private
  def is_confirm_allowed?
    # TODO: raise 401 Unauthorized / show decent "want another token?" page.
    raise unless Monban::IsConfirmationAllowed[params]
  end
end
