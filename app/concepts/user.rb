class User < ActiveRecord::Base
  has_many :ratings

  module Operation
    class Create < Trailblazer::Operation
      def process(params)
        User.create(params)
      end
    end

    class Confirm < Trailblazer::Operation
      class Contract < Reform::Form
        property :password, empty: true
        property :password_confirm, virtual: true, empty: true

        validates :password, presence: true, confirmation: true
      end

      def setup!(params) # TODO: man, abstract this into Operation::Model
        @model = User.find(params[:id])
      end

      def process(params)
        validate(params, @model) do

        end
      end
    end

    class Search < Trailblazer::Operation
      def process(params)
        User.where("email LIKE ?", "%#{params[:term]}%").collect do |usr|
          {value: "#{usr.id}", label: usr.email}
        end
      end
    end
  end


  class Twin < Disposable::Twin
    def avatar
      "/images/avatar.png"
    end

    def thumb
      "/images/avatar-thumb.png"
    end
  end
end