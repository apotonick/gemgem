module Trailblazer
  class Schema
    extend Uber::InheritableAttr
    self.inheritable_attr :block

    def self.define(&block)
      self.block = block
    end
  end
end