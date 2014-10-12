require 'trailblazer/operation'

class Thing < ActiveRecord::Base
  has_many :ratings
  has_and_belongs_to_many :authors,
    association_foreign_key: :user_id,
    foreign_key: :thing_id, class_name: "User" # seriouslaaayyyyy?

  serialize :image_meta_data

  include Paperdragon::Model
  processable :image


  module Schema
    include Reform::Form::Module

    property :name
    validates :name, presence: true

    collection :authors, embedded: true do
      property :email
      # validates :email, presence: true
      # validate :email_ok?
      validates_uniqueness_of :email
    end

  end


  module Representer
    include Roar::Representer::JSON::HAL

    module Validates
      def self.included(base)
        base.extend(Validates)
      end

      def validates(*)
      end
      def validates_uniqueness_of(*)
      end
      # def validate(*)
      # end
    end
    feature Validates

    include Schema

    # TODO: image_url: (only in representer!)

    link(:self) { thing_path(represented) }
  end


  module Operation
    class Show < Trailblazer::Operation
      def process(params)
        @model = Thing.find(params[:id])
      end

      # the official way here would be to
      # a) use roar-rails and just chuck @model to respond_with
      # b) implement Show::JSON, which is a lot of work. can we re-use from Create::JSON?
      def to_json(*)
        Representer.prepare(@model).to_json
      end
    end

    class Create < Trailblazer::Operation
      contract do
        include Schema
        model :thing # needed for form_for to figure out path.

        collection :authors, inherit: true,
          # TODO: this is no API logic.
          populate_if_empty: lambda { |hash, *| # next: Callable!
            (hash["id"].present? and User.find(hash["id"])) or User.new # API behaviour.
          },
          skip_if: :all_blank do

            validate :email_ok?

            def email=(value)
              return if persisted? # make email non-writable for existing users.
              super(value)
            end

            def email_ok?
              return if email.blank?
              errors.add("email", "wrong format") unless email =~ /@/ # yepp, i know.
            end

            property :id, virtual: true, empty: true
          end

        property :image, empty: true

        def image=(file)
          super Dragonfly.app.new_job(file)
        end

        # TODO: test for no image, pdf, png.
        extend Dragonfly::Model::Validations
        validates_property :format, of: :image, in: ['jpeg', 'png', 'gif']


        # presentation method
        def authors
          return [User.new] if super.blank? # here, i offer one form to enter an author.
          super
        end
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


      # FIXME: this is to make it work with a responder
      def self.model_name
        ::ActiveModel::Name.new(self, nil, "thing")
      end
      def to_param
        @model.to_param
      end
      def errors
        return [] if @valid
        [1]
      end



      class JSON < self
        contract do
          include Schema

          collection :authors, inherit: true,
            populate_if_empty: lambda { |hash, *| # next: Callable!
              (id = hash.delete("id") and User.find(id)) or User.new # API behaviour.
            } do
              property :email
            end

          self.representer_class.class_eval do
            include Representable::JSON
          end

          def deserialize_method
            :from_json
          end


        end

        def validate(params, *args)
          super(params[:request_body], *args) # TODO: make string first arg here.
        end


        # FIXME: this is to make it work with a responder
        def to_json(*) #
          # Problem with representer_class is that nested objects are forms.

          # Contract.representer_class.representable_attrs.get(:authors).merge!(prepare: nil)
          # Contract.representer_class.prepare(@model).to_json

          Representer.prepare(@model).to_json
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
        model.image(file) do |v|
          v.process!(:original)
          v.process!(:thumb) { |job| job.thumb!("72x72#") }
        end

        model.save
      end
    end

    require "reform/form/coercion"
    class Crop < Trailblazer::Operation
      class Contract < Reform::Form
        include Coercion
        properties [:x, :y, :w, :h], empty: true, type: Integer
        validates :x, :y, :w, :h, presence: true

        property :croppable_width, default: 300, type: Integer, empty: true

        model Thing
      end

      def process(params)
        @model = Thing.find(params[:id])

        # FIXME: when calling contract, why does this still return @model?
        validate(params, @model) do |contract|
          @model.image do |v|
            r = original_width / contract.croppable_width

            # contract.save do |h|
              # cropping = "#{(h[:w]*r).to_i}x#{(h[:w]*r).to_i}+#{(h[:x]*r).to_i}+#{(h[:y]*r).to_i}"
              cropping = "#{(contract.w*r).to_i}x#{(contract.h*r).to_i}+#{(contract.x*r).to_i}+#{(contract.y*r).to_i}"
              v.reprocess!(:thumb, Time.now.to_i) { |j| j.thumb!(cropping).thumb!("72x72#") }
            # end
            #   file type is wrong

          end

          @model.save
        end
      end

    private
      def original_width
        original = @model.image[:original]
        width    = original.metadata[:width].to_f
        # height   = original.metadata[:height]
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