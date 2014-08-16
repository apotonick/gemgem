require 'trailblazer/operation'

class Thing < ActiveRecord::Base
  has_many :ratings


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

      def process
        model = Thing.new

        validate(model, params) do |f|
          Uploads.run(params[:image]) # make this chainable. also, after validations (jpeg/png)

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


    class Uploads < Trailblazer::Operation
      def process#(file)
        file = params # I AM FUCKING STUPID AND FORGOT TO PUSH FROM MY WORK BOX!!!! :()
        versions = Image.new({}).task(file) # do |versions|
        versions.process!(:original) {}
        versions.process!(:thumb) { |job| job.thumb!("180x180#") }

        raise (versions.metadata.inspect)
        # @pic.update_attribute(:image_meta_data, versions.metadata)
      end
    end
  end


  class Image < Paperdragon::Attachment
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