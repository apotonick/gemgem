require 'trailblazer/operation'

class Thing < ActiveRecord::Base
  has_many :ratings
  def authors
    []
  end
  def authors=(*)

  end

  serialize :image_meta_data

  include Paperdragon::Model
  processable :image


  module Representer
    include Roar::Representer::JSON::HAL

    property :name

    collection :authors, embedded: true do
      property :email
    end

    link(:self) { thing_path(represented) }
  end


  module Form
    include Reform::Form::Module
    # include Representer

    property :name
    validates :name, presence: true
  end


  module Operation
    class Show < Trailblazer::Operation
      def process(params)
        Thing.find(params[:id])
      end
    end

    class Create < Trailblazer::Operation
      extend Flow

      class Contract < Reform::Form
        #include Form
        include Representer
        validates :name, presence: true


        model :thing # needed for form_for to figure out path.

        property :image, empty: true

        def image=(file)
          super Dragonfly.app.new_job(file)
        end

        # TODO: test for no image, pdf, png.
        extend Dragonfly::Model::Validations
        validates_property :format, of: :image, in: ['jpeg', 'png', 'gif']
      end

      def setup!(params)
        @model = Thing.new
      end
      attr_reader :model

      def process(params)
        # model = Thing.new

        validate(params, model) do |f| # image must be validated here!
          Upload.run(model, params[:image]) if params[:image] # make this chainable.

          f.save
        end
      end


      class JSON < self
        class Contract < Reform::Form
          self.representer_class.class_eval do
            include Representable::JSON
          end

          def deserialize_method
            :from_json
          end

          include Form
        end

        def validate(params, *args)
          super(params[:request_body], *args) # TODO: make string first arg here.
        end
      end
    end


    class Update < Create
      def setup!(params)
        @model = Thing.find(params[:id])
      end
    end


    class Upload < Trailblazer::Operation
      def process(model, file)
        # metadata = Image.new({}).task(file) do |v|
        metadata = model.image.task(file) do |v|
          v.process!(:original)
          v.process!(:thumb) { |job| job.thumb!("180x180#") }
        end

        # raise (versions.metadata.inspect)
        model.update_attribute(:image_meta_data, metadata)
      end
    end


    class Crop < Trailblazer::Operation
      class Contract < Reform::Form
        properties [:x, :y, :w, :h], empty: true
        model Thing
      end

      def process(params)
        @model = Thing.find(params[:id])

        # FIXME: when calling contract, why does this still return @model?
        validate(params, @model) do |contract|
          metadata = contract.model.image.task do |v|

            original = contract.model.image[:original] # FIXME: sucks

            width  = original.metadata[:width]
            height = original.metadata[:height]

            ratio_x = width.to_f / 300


            raise ratio_x.inspect

            raise width.inspect

            # FIXME: WE don't change filename (this gets appended which sucks)
            #   file type is wrong
            #   metadata should be ALL versions, not just thumb.
            v.reprocess!(:thumb, original) { |j| j.thumb!("#{contract.w}x#{contract.h}+#{contract.x}+#{contract.y}") }
          end
          puts metadata.inspect
        end
      end
    end
  end



  # new(twin).validate(params)[.save]
  # think of this as Operation::Update
  # class Operation < Trailblazer::Contract # "Saveable"

  #   class JSON < self
  #     include Trailblazer::Contract::JSON
  #     instance_exec(&Schema.block)
  #   end

  #   class Hash < self
  #     include Trailblazer::Contract::Hash
  #     instance_exec(&Schema.block)
  #   end

  #   class Form < Reform::Form
  #     include Trailblazer::Contract::Flow
  #     instance_exec(&Schema.block)

  #     model :thing
  #   end
  # end

  # ContentOrchestrator -> Endpoint:
  # Thing::Operation::Create.call({..}) # "model API"
  # Thing::Operation::Create::Form.call({..})
  # Thing::Operation::Create::JSON.call({..})

  # endpoint is kind of multiplexer for different formats in one action.
  # it then calls one "CRUD" operation.
end