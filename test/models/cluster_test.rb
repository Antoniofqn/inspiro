require "test_helper"

class ClusterTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @cluster = Cluster.new(name: "Research Notes", user: @user)
  end

  test "should be valid with valid attributes" do
    assert @cluster.valid?
  end

  test "should require a name" do
    @cluster.name = nil
    assert_not @cluster.valid?
  end

  test "should belong to a user" do
    @cluster.user = nil
    assert_not @cluster.valid?
  end

  test "should not allow duplicate names for the same user" do
    @cluster.save
    duplicate_cluster = @cluster.dup
    assert_not duplicate_cluster.valid?
  end
end
