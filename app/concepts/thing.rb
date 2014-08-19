require 'trailblazer/operation'

class Thing < ActiveRecord::Base
  has_many :ratings

  serialize :image_meta_data


  class Image < Paperdragon::Attachment
  end
  include Paperdragon::Model
  processable :image, Image


  module Form
    include Reform::Form::Module

    property :name
    validates :name, presence: true
  end


  module Operation
    class Create < Trailblazer::Operation
      extend Flow

      class Contract < Reform::Form
        include Form
        model :thing # needed for form_for to figure out path.
      end

      def process(params)
        model = Thing.new

        validate(model, params) do |f|
          Upload.run(model, params[:image]) if params[:image] # make this chainable. also, after validations (jpeg/png)

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
      end
    end


    class Upload < Trailblazer::Operation
      def process(model, file)
        metadata = Image.new({}).task(file) do |v|
          v.process!(:original) {}
          v.process!(:thumb) { |job| job.thumb!("180x180#") }
        end

        # raise (versions.metadata.inspect)
        model.update_attribute(:image_meta_data, metadata)
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