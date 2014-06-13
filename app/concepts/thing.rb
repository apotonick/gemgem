module Thing
  class Persistence < ActiveRecord::Base
    self.table_name = :things

    has_many :ratings, class_name: Rating::Persistence, foreign_key: :thing_id
  end

  class Twin < Disposable::Twin
    model Persistence

    property :name
    property :id # FIXME: why do i need this, again? should be infered.
    collection :ratings, twin: ->{Rating::Twin}

    def persisted?
      model.persisted?
    end

    def self.model_name
      ::ActiveModel::Name.new(self, nil, "Thing") # Twin::ActiveModel should implement that. as a sustainable fix, we should simplify routing helpers.
    end

    def to_key
    #   return [1]
      model.to_key
    end

    # DISCUSS: this is used in simple_form_for [Rateable::Entity.new, @form] to compute nested URL. there must be a stupid respond_tp?(to_param) call in the URL helpers - remove that in Trailblazer.
    def to_param
      1
    end
  end

  class Contract < Reform::Contract
    property :name, presentation_accessors: true
    validates :name, presence: true
  end

  module Schema
    include Representable
    representable_attrs.inherit Contract.representer_class.representable_attrs
  end

  class Form < Reform::Form
    property :name
    validates :name, presence: true

    model Thing
  end

  # new(twin).validate(params)[.save]
  class Operation < Trailblazer::Contract # "Validate- and Saveable"
    include Trailblazer::Operation
    # include Rating::Representer

    # include Representable
    # include Schema
    representer_class.representable_attrs.inherit Schema.representable_attrs

    def id
      model.thing.id # FIXME.
    end

    class JSON < self
      include Trailblazer::Contract::JSON
    end

    class Hash < self
      include Trailblazer::Contract::Hash
    end
  end

  # ContentOrchestrator -> Endpoint:
  # Thing::Operation::Create.call({..}) # "model API"
  # Thing::Operation::Create::Form.call({..})
  # Thing::Operation::Create::JSON.call({..})

  # endpoint is kind of multiplexer for different formats in one action.
  # it then calls one "CRUD" operation.
end