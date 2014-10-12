class SessionsController < ApplicationController
  def new
    @form = Session::Signin.present({})
  end

  # TODO: test me.
  def create
    @form = Session::Signin.run(params[:session]) do |op|
      sign_in(op)
      return redirect_to things_path
    end.contract

    render action: :new
  end

  # TODO: test me.
  def signout
    Session::Signout.run({}) do
      sign_out
      redirect_to things_path
    end
  end
end