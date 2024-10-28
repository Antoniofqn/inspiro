require "test_helper"

class TagTest < ActiveSupport::TestCase
  def setup
    @user = users(:one) # Fixture user
    @tag = Tag.new(name: "Test Tag", user: @user)
  end

  test "should be valid with valid attributes" do
    assert @tag.valid?
  end

  test "should require a name" do
    @tag.name = nil
    assert_not @tag.valid?
  end

  test "should belong to a user" do
    @tag.user = nil
    assert_not @tag.valid?
  end

  test "should be unique per user" do
    duplicate_tag = @tag.dup
    @tag.save
    assert_not duplicate_tag.valid?
  end
end
