require 'test_helper'

class ActsAsNestedIntervalTest < ActiveSupport::TestCase
  def test_modular_inverse
    assert_equal [nil, 1, 5, nil, 7, 2, nil, 4, 8], (0...9).map { |k| k.inverse(9) }
  end

  def test_create_root
    earth = Region.create :name => "Earth"
    assert_equal [0, 1], [earth.lftp, earth.lftq]
    assert_equal [1, 1], [earth.rgtp, earth.rgtq]
    assert_equal 1.0 * 0 / 1, earth.lft
    assert_equal 1.0 * 1 / 1, earth.rgt
    assert_equal [earth], Region.roots
  end

  def test_create_first_child
    earth = Region.new :name => "Earth"
    oceania = Region.new :name => "Oceania", :parent => earth
    oceania.save!
    assert_equal [1, 2], [oceania.lftp, oceania.lftq]
    assert_equal [1, 1], [oceania.rgtp, oceania.rgtq]
    assert_equal 1.0 * 1 / 2, oceania.lft
    assert_equal 1.0 * 1 / 1, oceania.rgt
  end

  def test_create_second_child
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    assert_equal [2, 3], [australia.lftp, australia.lftq]
    assert_equal [1, 1], [australia.rgtp, australia.rgtq]
    assert_equal 1.0 * 2 / 3, australia.lft
    assert_equal 1.0 * 1 / 1, australia.rgt
    assert_equal [3, 5], [new_zealand.lftp, new_zealand.lftq]
    assert_equal [2, 3], [new_zealand.rgtp, new_zealand.rgtq]
    assert_equal 1.0 * 3 / 5, new_zealand.lft
    assert_equal 1.0 * 2 / 3, new_zealand.rgt
  end

  def test_append_child
    earth = Region.create :name => "Earth"
    oceania = Region.new :name => "Oceania"
    earth.children << oceania
    assert_equal [1, 2], [oceania.lftp, oceania.lftq]
    assert_equal [1, 1], [oceania.rgtp, oceania.rgtq]
    assert_equal 1.0 * 1 / 2, oceania.lft
    assert_equal 1.0 * 1 / 1, oceania.rgt
  end

  def test_ancestors
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    assert_equal [], earth.ancestors
    assert_equal [earth], oceania.ancestors
    assert_equal [earth, oceania], australia.ancestors
    assert_equal [earth, oceania], new_zealand.ancestors
  end

  def test_descendants
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    assert_equal [oceania, australia, new_zealand], earth.descendants.sort_by(&:id)
    assert_equal [australia, new_zealand], oceania.descendants.sort_by(&:id)
    assert_equal [], australia.descendants.sort_by(&:id)
    assert_equal [], new_zealand.descendants.sort_by(&:id)
  end

  def test_preorder
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    antarctica = Region.create :name => "Antarctica", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    assert_equal [earth, oceania, australia, new_zealand, antarctica], Region.preorder
  end

  def test_depth
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    assert_equal 0, earth.depth
    assert_equal 1, oceania.depth
    assert_equal 2, australia.depth
    assert_equal 2, new_zealand.depth
  end

  def test_move
    connection = Region.connection
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    assert_raise ActiveRecord::RecordInvalid do
      oceania.parent = oceania
      oceania.save!
    end
    assert_raise ActiveRecord::RecordInvalid do
      oceania.parent = australia
      oceania.save!
    end
    pacific = Region.create :name => "Pacific", :parent => earth
    assert_equal [1, 3], [pacific.lftp, pacific.lftq]
    assert_equal [1, 2], [pacific.rgtp, pacific.rgtq]
    assert_equal 1.0 * 1 / 3, pacific.lft
    assert_equal 1.0 * 1 / 2, pacific.rgt
    oceania.parent = pacific
    oceania.save!
    assert_equal [0, 1], [earth.lftp, earth.lftq]
    assert_equal [1, 1], [earth.rgtp, earth.rgtq]
    assert_equal 1.0 * 0 / 1, earth.lft
    assert_equal 1.0 * 1 / 1, earth.rgt
    assert_equal [1, 3], [pacific.lftp, pacific.lftq]
    assert_equal [1, 2], [pacific.rgtp, pacific.rgtq]
    assert_equal 1.0 * 1 / 3, pacific.lft
    assert_equal 1.0 * 1 / 2, pacific.rgt
    assert_equal [2, 5], [oceania.lftp, oceania.lftq]
    assert_equal [1, 2], [oceania.rgtp, oceania.rgtq]
    assert_equal 1.0 * 2 / 5, oceania.lft
    assert_equal 1.0 * 1 / 2, oceania.rgt
    australia.reload
    assert_equal [3, 7], [australia.lftp, australia.lftq]
    assert_equal [1, 2], [australia.rgtp, australia.rgtq]
    assert_equal 1.0 * 3 / 7, australia.lft
    assert_equal 1.0 * 1 / 2, australia.rgt
    new_zealand.reload
    assert_equal [5, 12], [new_zealand.lftp, new_zealand.lftq]
    assert_equal [3, 7], [new_zealand.rgtp, new_zealand.rgtq]
    assert_equal 1.0 * 5 / 12, new_zealand.lft
    assert_equal 1.0 * 3 / 7, new_zealand.rgt
  end

  def test_destroy
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    australia = Region.create :name => "Australia", :parent => oceania
    new_zealand = Region.create :name => "New Zealand", :parent => oceania
    oceania.destroy
    assert_equal [], earth.descendants
  end

  def test_scope
    earth = Region.create :name => "Earth"
    oceania = Region.create :name => "Oceania", :parent => earth
    krypton = Region.create :name => "Krypton", :fiction => true
    assert_equal [earth], oceania.ancestors
    assert_equal [], krypton.descendants
  end

  def test_limits
    region = Region.create :name => ""
    22.times do
      Region.create :name => "", :parent => region
      region = Region.create :name => "", :parent => region
    end
    region.descendants
  end
end