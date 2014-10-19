class User < ActiveRecord::Base
  has_many :ratings

  include Paperdragon::Model
  processable :image
  serialize :image_meta_data

  require_dependency 'user/update'

  module Operation
    class Create < Trailblazer::Operation
      def process(params)
        User.create(params)
      end
    end

    # should we check IsConfirmationAllowed? here?
    class Confirm < Trailblazer::Operation
      contract do
        model :user

        property :password, empty: true
        property :password_confirmation, empty: true

        validates :password, presence: true, confirmation: true
        validates :password_confirmation, presence: true
      end

      def setup!(params) # TODO: man, abstract this into Operation::Model
        @model = User.find(params[:id])
      end

      def process(params)
        validate(params[:user], @model) do |f|
          # note how i don't call f.save here.
          Monban::Confirm[id: params[:id], password: f.to_hash[:password]]
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

  class Show < Trailblazer::Operation
    include CRUD
    model User, :update

    def process(*)
      # TODO: provide by CRUD.
      self
    end

    class JSON < self
      include Representer
      include Responder
      self.representer_class = Update::JSON.representer_class
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