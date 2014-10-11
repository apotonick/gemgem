class UsersController < ApplicationController
  respond_to :json#, :html

  def search
    respond_with User::Operation::Search[params]
    # render json: [{"label"=>"mylabel","value"=>"myvalue"}]
  end

  class Endpoint
    def to_html # better: call(:html) as this handles parse+render
      "ficken"
      # cell would handle everything
    end # this doesn't work, the responder calls default_render instead of my to_html
  end

  # no #validate!
  def present(operation_class, params=self.params)
    yield operation_class.new(:validate => false).run(params).last # FIXME: make that available via Operation.
  end

  # full-on Op[]
  def run(operation_class, params=self.params)
    yield operation_class[params]
  end
  private :present, :run

  def edit
    # TODO: authorization

    present User::Update do |op| # this runs op."contract" but returns the op. Op#init ?
      # this is absolutely ok here - this is presentation logic only for HTML.
      # i could also use User::Edit but i don't need it presently.
      @form = op.contract
    end
  end

  def update
    run User::Update do |op|
      # html only.
      flash[:notice] = "Updated."
  render action: edit
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
