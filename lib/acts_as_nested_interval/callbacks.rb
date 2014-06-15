module ActsAsNestedInterval
  module Callbacks
    extend ActiveSupport::Concern

    included do

      before_create :create_nested_interval
      before_destroy :destroy_nested_interval
      before_update :update_nested_interval
        
    end

    # Destroys record.
    def destroy_nested_interval
      lock! rescue nil
    end

    # Creates record.
    def create_nested_interval
      if read_attribute(nested_interval.foreign_key).nil?
        set_nested_interval_for_top
      else
        set_nested_interval *parent.lock!.next_child_lft
      end
    end

    # Updates record, updating descendants if parent association updated,
    # in which case caller should first acquire table lock.
    def update_nested_interval
      unless node_moved?
        db_self = self.class.find(id).lock!
        write_attribute(nested_interval.foreign_key, db_self.read_attribute(nested_interval.foreign_key))
        set_nested_interval db_self.lftp, db_self.lftq
      else
        # No locking in this case -- caller should have acquired table lock.
        update_nested_interval_move
      end
    end
    
  end
end
