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

  # ContentOrchestrator -> Endpoint:
  # Thing::Operation::Create.call({..}) # "model API"
  # Thing::Operation::Create::Form.call({..})
  # Thing::Operation::Create::JSON.call({..})

  class Endpoint # in Trailblazer, controllers are Endpoints. they shouldn't be overridden as they do pretty generic shit.
    class Create

      def call(controller, params)
        thing = domain::Twin.new

        # TODO: no json or http stuff in here!
        is_json = controller.request.format == "application/json"
        @form = (is_json ? domain::Operation::JSON : domain::Form).new(thing)
        input = is_json ? controller.request.body.string : params[:thing]

        @form.extend(domain::Operation::Flow) # FIXME: Only for fuckin Form.
        @form.flow(controller, input) # TODO: remove dependency
      end

    private
      def domain
        Thing
      end
    end
  end
end