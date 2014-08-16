class User < ActiveRecord::Base
  module Operation
    class Create < Trailblazer::Operation
      def process#(params)
        User.create(params)
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