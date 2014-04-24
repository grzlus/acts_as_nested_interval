class Region < ActiveRecord::Base
  include ActsAsNestedInterval

  acts_as_nested_interval :foreign_key => :region_id, :scope_columns => :fiction
end
