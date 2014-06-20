using Mediant

module ActsAsNestedInterval
  module InstanceMethods

    extend ActiveSupport::Concern
    
    # selectively define #descendants according to table features
    included do
      validate :disallow_circular_dependency
    end
    
    def set_nested_interval(rational)
      self.lftp, self.lftq = rational.numerator, rational.denominator
      self.rgtp = rgtp if has_attribute?(:rgtp)
      self.rgtq = rgtq if has_attribute?(:rgtq)
      self.lft = lft if has_attribute?(:lft)
      self.rgt = rgt if has_attribute?(:rgt)
    end
    
    def nested_interval_scope
      conditions = {}
      nested_interval.scope_columns.each do |column_name|
        conditions[column_name] = send(column_name)
      end
      self.class.where conditions
    end

    def recalculate_nested_interval!
      move! do
        lftr = parent.present? ? parent.next_child_lft : next_root_lft
        set_nested_interval( lftr )
        save!
        self.recalculate_nested_interval!
        children.preorder.map(&:recalculate_nested_interval!)
      end
    end

    # Rewrite method
    def update_nested_interval_move
      return unless self.class.nested_interval.moveable?

      if parent.present? and self.ancestor_of?(parent)
        errors.add nested_interval.foreign_key, "is descendant"
        raise ActiveRecord::RecordInvalid, self
      end

      # TODO: Do it by DB
      self.recalculate_nested_interval!
    end
    
    # Returns depth by counting ancestors up to 0 / 1.
    def depth
      if new_record?
        if parent.nil?
          return 0
        else
          return parent.depth + 1
        end
      else
        n = 0
        p, q = lftp, lftq
        while p != 0
          x = p.inverse(q)
          p, q = (x * p - 1) / q, x
          n += 1
        end
        return n
      end
    end

    def lft; 1.0 * lftp / lftq end
    def rgt; 1.0 * rgtp / rgtq end

    # Returns numerator of right end of interval.
    def rgtp
      case lftp
      when 0 then 1
      when 1 then 1
      else lftq.inverse(lftp)
      end
    end

    # Returns denominator of right end of interval.
    def rgtq
      case lftp
      when 0 then 1
      when 1 then lftq - 1
      else (lftq.inverse(lftp) * lftq - 1) / lftp
      end
    end

    # Returns left end of interval for next child.
    def next_child_lft
      if child = children.order('lftq DESC').first
        return left.mediant( child.left )
      else
        return left.mediant( right )
      end
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
