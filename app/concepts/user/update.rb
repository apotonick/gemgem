class User < ActiveRecord::Base
  class Update < Trailblazer::Operation
    class Contract < Reform::Form
      model User

      property :name
      property :email
      property :image, file: true

      # TODO: validations for image.
    end

    include CRUD
    model User, :update

    def process(params)
      validate(params) do
        file = params[:user][:image]

        model.image(file) do |v|
          v.process!(:original)
          v.process!(:thumb)   { |job| job.thumb!("75x75#") }
        end

        model.save
      end
    end
  end
end