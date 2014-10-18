class User < ActiveRecord::Base
  class Update < Trailblazer::Operation
    contract do
      include Reform::Form::SkipUnchanged # TODO: DEFAULT in trailblazer.
      model User

      property :name
      property :email, validates: {presence: true}
      property :image, file: true, virtual: true

      # TODO: validations for image.
    end

    include CRUD
    model User, :update

    def process(params)
      validate(params[:user]) do |f|
        # now, the image is validated, but not processed, yet!

        # we could also use save {}, explain in book!
        # f.sync(self, image: :upload!)
        f.save(image: lambda { |file, *| upload!(file) })
        f.model.save # to save changes to image_meta_data.

        puts "+++++++++++++++ #{f.model.inspect}"
      end
    end

  private
    def upload!(file)
      model.image(file) do |v|
        v.process!(:original)
        v.process!(:thumb)   { |job| job.thumb!("75x75#") }
      end
    end

    class JSON < self
      include Representer
      include Responder

      contract do
        include Reform::Form::JSON
      end

      representer do
        include Roar::Hypermedia
        include Roar::JSON
        link(:self) { "http://users/#{represented.id}" }

        def image
          return unless represented.image.exists?
          represented.image[:thumb].url
        end

        property :image, exec_context: :decorator
      end
    end
  end
end