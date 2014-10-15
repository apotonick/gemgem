class User < ActiveRecord::Base
  class Update < Trailblazer::Operation
    contract do
      include Reform::Form::SkipUnchanged # TODO: DEFAULT in trailblazer.
      model User

      property :name
      property :email, validates: {presence: true}
      property :image, file: true, sync: lambda { |file, *|
        model.image(file) do |v|
          v.process!(:original)
          v.process!(:thumb)   { |job| job.thumb!("75x75#") }
        end } # :sync will be Twin job at some point.

      # TODO: validations for image.
    end

    include CRUD
    model User, :update

    def process(params)
      # file = params[:user].delete(:image) if params[:user].is_a?(Hash) # FIXME: that sucks.

      validate(params[:user]) do |f|
        # now, the image is validated, but not processed, yet!

        # we could also use save {}, explain in book!

        # if file
        #   model.image(file) do |v|
        #     v.process!(:original)
        #     v.process!(:thumb)   { |job| job.thumb!("75x75#") }
        #   end
        # end

        f.save#(self, sync: {image: :upload!})
        puts "+++++++++++++++ #{f.model.inspect}"
      end
    end


    class JSON < self
      contract do
        include Reform::Form::JSON
      end
    end
  end
end