# Copyright (c) 2007, 2008 Pythonic Pty Ltd
# http://www.pythonic.com.au/

# Copyright (c) 2012 Nicolae Claudius
# https://github.com/clyfe

require 'acts_as_nested_interval/core_ext/integer'
require 'acts_as_nested_interval/version'
require 'acts_as_nested_interval/constants'
require 'acts_as_nested_interval/configuration'
require 'acts_as_nested_interval/callbacks'
require 'acts_as_nested_interval/instance_methods'
require 'acts_as_nested_interval/class_methods'

# This act implements a nested-interval tree. You can find all descendants
# or all ancestors with just one select query. You can insert and delete
# records without a full table update.
module ActsAsNestedInterval
  extend ActiveSupport::Concern
  
  module ClassMethods

    # The +options+ hash can include:
    # * <tt>:foreign_key</tt> -- the self-reference foreign key column name (default :parent_id).
    # * <tt>:scope_columns</tt> -- an array of columns to scope independent trees.
    # * <tt>:lft_index</tt> -- whether to use functional index for lft (default false).
    # * <tt>:virtual_root</tt> -- whether to compute root's interval as in an upper root (default false)
    # * <tt>:dependent</tt> -- dependency between the parent node and children nodes (default :restrict)
    def acts_as_nested_interval(options = {})
      # Refactored
      # TODO: table_exists?
      cattr_accessor :nested_interval

      self.nested_interval = Configuration.new( self, **options )

      if nested_interval.fraction_cache?
        scope :preorder, -> { order(rgt: :desc, lftp: :asc) }
      else
        scope :preorder, -> { order('1.0 * rgtp / rgtq DESC, lftp ASC') }
      end
      # When?
      #scope :preorder, -> { order('nested_interval_rgt(lftp, lftq) DESC, lftp ASC') }


      # OLD CODE
      #cattr_accessor :nested_interval_foreign_key
      cattr_accessor :nested_interval_scope_columns
      cattr_accessor :nested_interval_lft_index
      cattr_accessor :nested_interval_dependent

      cattr_accessor :virtual_root
      self.virtual_root = !!options[:virtual_root]

      #self.nested_interval_foreign_key = options[:foreign_key] || :parent_id
      self.nested_interval_scope_columns = Array(options[:scope_columns])
      self.nested_interval_lft_index = options[:lft_index]
      self.nested_interval_dependent = options[:dependent] || :restrict_with_exception

      belongs_to :parent, class_name: name, foreign_key: nested_interval.foreign_key
      has_many :children, class_name: name, foreign_key: nested_interval.foreign_key,
        dependent: nested_interval.dependent
      scope :roots, -> { where(nested_interval.foreign_key => nil) }

      if self.table_exists? # Fix problem with migrating without table
        include ActsAsNestedInterval::InstanceMethods
        include ActsAsNestedInterval::Callbacks
        extend ActsAsNestedInterval::ClassMethods
      end
    end
  end
end

#ActiveRecord::Base.send :extend, ActsAsNestedInterval
