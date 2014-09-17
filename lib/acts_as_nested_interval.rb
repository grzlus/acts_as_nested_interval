# Copyright (c) 2007, 2008 Pythonic Pty Ltd
# http://www.pythonic.com.au/

# Copyright (c) 2012 Nicolae Claudius
# https://github.com/clyfe

require 'acts_as_nested_interval/core_ext/integer'
require 'acts_as_nested_interval/core_ext/rational'
require 'acts_as_nested_interval/core_ext/arel'
require 'acts_as_nested_interval/version'
require 'acts_as_nested_interval/constants'
require 'acts_as_nested_interval/configuration'
require 'acts_as_nested_interval/callbacks'
require 'acts_as_nested_interval/instance_methods'
require 'acts_as_nested_interval/class_methods'
require 'acts_as_nested_interval/associations'
require 'acts_as_nested_interval/calculate'
require 'acts_as_nested_interval/moving'

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
      cattr_accessor :nested_interval

      self.nested_interval = Configuration.new( self, **options )

      if self.table_exists? # Fix problem with migrating without table
        include ActsAsNestedInterval::Calculate
        include ActsAsNestedInterval::Moving
        include ActsAsNestedInterval::InstanceMethods
        include ActsAsNestedInterval::Callbacks
        include ActsAsNestedInterval::Associations
        extend ActsAsNestedInterval::ClassMethods
      end

      calculate(*([:lft, :rgt, :rgtq, :rgtp] & self.columns.map {|c| c.name.to_sym }))
    end
  end
end

