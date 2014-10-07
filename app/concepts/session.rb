module Session
  class Signin < Trailblazer::Operation
    class Contract < Reform::Form
      include ModelReflections
      property :email,    empty: true
      property :password, empty: true

      validates :email, :password, presence: true
      validate :password_ok?

      def persisted?
        false
      end
      def to_key
        nil
      end
      model :session

      undef_method :column_for_attribute # TODO: allow un-ARed forms in Reform/Rails.

    private
      def password_ok?
        # DISCUSS: move validation of PW to Op#process?
        user = User.find_by_email(email)
        errors.add(:password, "wrong") unless Monban.config.authentication_service.new(user, password).perform
      end
    end


    def process(params)
      # model = User.find_by_email(email) 00000> pass user into form?
      validate(params, nil) do |contract|
        return User.find_by_email contract.email # TODO: do that once.
      end
    end
  end

  class Signout < Trailblazer::Operation
    def process(params)
      # empty for now, this could e.g. log signout, etc.
    end
  end
end