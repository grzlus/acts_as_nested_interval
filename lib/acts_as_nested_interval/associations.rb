module ActsAsNestedInterval
  module Associations
    extend ActiveSupport::Concern

    included do 
      belongs_to :parent, class_name: name, foreign_key: nested_interval.foreign_key
      has_many :children, class_name: name, foreign_key: nested_interval.foreign_key,
        dependent: nested_interval.dependent
      scope :roots, -> { where(nested_interval.foreign_key => nil) }

      scope :ancestors_of, ->(node){ where("rgt >= CAST(:rgt AS FLOAT) AND lft < CAST(:lft AS FLOAT)", rgt: node.rgt, lft: node.lft) }
      scope :subtree_of, ->(node){ where( "lft >= :lft AND rgt <= :rgt", rgt: node.rgt, lft: node.lft ) } # Simple version
      scope :descendants_of, ->(node){ subtree_of(node).where.not(id: node.id) }
      scope :siblings_of, ->(node){ fkey = nested_interval.foreign_key; where( fkey => node.send(fkey) ).where.not(id: node.id) }

      if nested_interval.fraction_cache?
        scope :preorder, -> { order(rgt: :desc, lftp: :asc) }
      else
        scope :preorder, -> { order('1.0 * rgtp / rgtq DESC, lftp ASC') }
      end
    end

    def ancestor_of?(node)
      left < node.left && right >= node.right
    end

    def ancestors
      nested_interval_scope.ancestors_of(self)
    end

    def descendants
      nested_interval_scope.descendants_of(self)
    end

    def siblings
      nested_interval_scope.siblings_of(self)
    end


  end
end
