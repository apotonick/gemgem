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


    module Responder
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def model_name
          ::ActiveModel::Name.new(self, nil, "thing")
        end
      end

      def to_param
        @model.to_param
      end

      def errors
        return [] if @valid
        [1]
      end

      def to_json(*)
        self.class.contract_class.new(model).to_json
      end
    end

    require "roar/json"
    require "roar/hypermedia"
    class JSON < self
      contract do
        include Reform::Form::JSON



        representer_class.class_eval do
          include Roar::Hypermedia
          include Roar::JSON
          link(:self) { "http://users/#{represented.id}" }

          def image
            super[:thumb].url
          end
        end
      end

      include Responder
    end
  end
end