class User < ActiveRecord::Base
  module Operation
    class Create < Trailblazer::Operation
      def process(params)
        User.create(params)
      end
    end

    class Search < Trailblazer::Operation
      def process(params)
        User.where("email LIKE ?", "%#{params[:term]}%").collect do |usr|
          {value: usr.id, label: usr.email}
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