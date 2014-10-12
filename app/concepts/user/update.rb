class User < ActiveRecord::Base
  class Update < Trailblazer::Operation
    contract do
      model User

      property :name
      property :email, validates: {presence: true}
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

      validate(params[:user]) do |f|
        # now, the image is validated, but not processed, yet!

        if file
          model.image(file) do |v|
            v.process!(:original)
            v.process!(:thumb)   { |job| job.thumb!("75x75#") }
          end
        end

        f.save
      end
    end


    class JSON < self
      contract do
        representer_class.send(:include, Representable::JSON)

        def deserialize_method
          :from_json
        end
      end

       # def process(params)
       #   validate(params[:user]) do
       #      model.save
       #   end
       # end
    end
  end
end