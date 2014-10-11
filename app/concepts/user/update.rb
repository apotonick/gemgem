class User < ActiveRecord::Base
  class Update < Trailblazer::Operation
    class Contract < Reform::Form
      model User

      property :name
      property :email
      property :image, file: true, virtual: true, sync: lambda { |image|
        model.image(file) do |v|
          v.process!(:original)
          v.process!(:thumb)   { |job| job.thumb!("75x75#") }
        end } # :sync will be Twin job at some point.

      # TODO: validations for image.
    end

    include CRUD
    model User, :update

    def process(params)
      file = params[:user].delete(:image) if params[:user].is_a?(Hash) # FIXME: that sucks.

      validate(params) do |f|
        # now, the image is validated, but not processed, yet!

        model.image(file) do |v|
          v.process!(:original)
          v.process!(:thumb)   { |job| job.thumb!("75x75#") }
        end

        f.save
      end
    end
  end
end