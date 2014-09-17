using Mediant
using ArelHack

module ActsAsNestedInterval
  module InstanceMethods

    extend ActiveSupport::Concern
    
    included do
      validate :disallow_circular_dependency
    end
    
    def set_nested_interval(rational)
      self.lftp, self.lftq = rational.numerator, rational.denominator
      [:lft, :rgtq, :rgtp, :rgt].each do |attr|
        send("#{attr}=", nil)
        send(attr)
      end
      #self.rgtp = rgtp if has_attribute?(:rgtp)
      #self.rgtq = rgtq if has_attribute?(:rgtq)
      #self.lft = lft if has_attribute?(:lft)
      #self.rgt = rgt if has_attribute?(:rgt)
    end
    
    def nested_interval_scope
      conditions = {}
      nested_interval.scope_columns.each do |column_name|
        conditions[column_name] = send(column_name)
      end
      self.class.where conditions
    end

    # Returns left end of interval for next child.
    def next_child_lft
      left.mediant( children.last.try(:left) || right )
    end
    
    # Returns left end of interval for next root.
    def next_root_lft
      last_root = nested_interval_scope.roots.order( rgtp: :desc, rgtq: :desc ).first
      raise Exception.new("Only one root allowed") if last_root.present? && !self.class.nested_interval.multiple_roots?
      last_root.try(:right) || 0.to_r
    end
    
    # Check if node is moved (parent changed)
    def node_moved?
      send(:"#{nested_interval.foreign_key}_changed?") # TODO: Check if parent moved?
    end

    def left
      Rational(lftp, lftq)
    end

    def right
      Rational(rgtp, rgtq)
    end

    protected

    def disallow_circular_dependency
      if parent == self
        errors.add(self.class.nested_interval.foreign_key, 'cannot refer back to self')
      end
    end

  end
end
