require 'trailblazer/operation'

module Thing
  class Persistence < ActiveRecord::Base
    self.table_name = :things

    has_many :ratings, class_name: Rating::Persistence, foreign_key: :thing_id
  end


  class Form < Reform::Form
    property :name
    validates :name, presence: true
  end

  module Operation
    class Create < Trailblazer::Operation
      extend Flow

      def run(params)
        model = Thing::Persistence.new

        validate(model, params, Form) do |f|
          f.save
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