module ActsAsNestedInterval
  module Callbacks
    extend ActiveSupport::Concern

    included do

      before_create :create_nested_interval
      before_destroy :destroy_nested_interval
      before_update :update_nested_interval, if: :node_moved?
        
    end

    # Destroys record.
    def destroy_nested_interval
      lock! rescue nil
    end

    # Creates record.
    def create_nested_interval
      set_nested_interval(parent.present? ? parent.next_child_lft : next_root_lft )
    end

    # Updates record, updating descendants if parent association updated,
    # in which case caller should first acquire table lock.
    def update_nested_interval
      return if moving?
      raise Exception.new("Node moved in non moveable model") unless self.class.nested_interval.moveable?
      # Why we need this?
      #db_self = self.class.find(id).lock!
      #write_attribute(nested_interval.foreign_key, db_self.read_attribute(nested_interval.foreign_key))
      #set_nested_interval Rational(db_self.lftp, db_self.lftq)
      update_nested_interval_move
    end

    def move!
      return if moving?
      self.class.nested_interval.moving = true
      transaction do
        yield 
      end
    ensure
      self.class.nested_interval.moving = false
    end

    def moving?
      !!self.class.nested_interval.moving
    end
    
  end
end
