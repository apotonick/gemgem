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

    collection :authors, embedded: true do
      property :email
    end
  end

  class Create < Trailblazer::Operation
    include CRUD
    model Thing, :create

    include Trailblazer::Operation::Representer
    include Responder

    contract do
      include Schema
      model :thing # needed for form_for to figure out path.

      validates :name, presence: true

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

          validates_uniqueness_of :email
        end

      property :image, empty: true

      validates :image, file_size: {less_than: 2.megabytes},
        file_content_type: {allow: ['image/jpeg', 'image/png', 'image/gif']}

      # presentation method
      def authors
        return [User.new] if super.blank? # here, i offer one form to enter an author.
        super
      end
    end

    def process(params)
      validate(params[:thing]) do |f| # image must be validated here!

        if file = params[:thing][:image]
          model.image(file) do |v|
            v.process!(:original)
            v.process!(:thumb) { |job| job.thumb!("72x72#") }
          end
        end

        f.save
      end
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

        include Reform::Form::JSON
      end

      self.representer_class = class Representer < Representable::Decorator
        include Roar::JSON::HAL
        include Schema

        def thing_path(model) # FIXME: make url helpers work here without roar-rails, we don't need it.
          "/things/#{model.id}"
        end

        link(:self) { thing_path(represented) }
        self
      end
    end
  end


  class Update < Create
    def setup!(params)
      @model = Thing.find(params[:id])
    end
  end

  class Show < Create
    def process(params)
      @model = Thing.find(params[:id])
      self
    end

    class JSON < self
      self.representer_class = Create::JSON.representer_class
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