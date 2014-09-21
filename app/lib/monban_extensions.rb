module Monban
  class ConfirmLater < Trailblazer::Operation
    def process(params)
      @model = User.find(params[:id])
      @model.update_attributes(confirmation_token: "abc123")
    end
  end

  class IsConfirmationAllowed < Trailblazer::Operation
    def process(params)
      @model = User.find(params[:id])
      @model.confirmation_token == params[:confirmation_token]
    end
  end

  class Confirm < Trailblazer::Operation
    # this should include Monban::SignUp.
    def process(params)
      digest = Monban.hash_token(params[:password])
      @model = User.find(params[:id])
      @model.update_attributes(
        password_digest: digest,
        confirmation_token: nil)
    end
  end
end