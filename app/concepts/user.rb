class User < ActiveRecord::Base
  module Operation
    class Create < Trailblazer::Operation
      def process#(params)
        User.create(params)
      end
    end
  end
end