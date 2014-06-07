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
    property :name
    validates :name, presence: true
  end

  require 'representable/decorator'
  class Representer < Representable::Decorator
    include Representable::JSON

    @representable_attrs = Contract.representer_class.representable_attrs
  end

  class Form < Reform::Form
    property :name
    validates :name, presence: true

    model Thing
  end

  # ContentOrchestrator:
  # Thing::Operation::Create.call({..}) # "model API"
  # Thing::Operation::Create::Form.call({..})
  # Thing::Operation::Create::JSON.call({..})

  class Operation
    class Create

      def self.fixme_for_form_and_json(controller, params)
        thing = Thing::Twin.new

        # TODO: no json or http stuff in here!
        is_json = controller.request.format == "application/json"
        @form = (is_json ? Thing::Eva::JSON : Thing::Form).new(thing)
        input = is_json ? controller.request.body.string : params[:thing]

        @form.extend(Thing::Eva::Flow) # FIXME: Only for fuckin Form.
        @form.flow(controller, input) # TODO: remove dependency
      end
    end
  end
end