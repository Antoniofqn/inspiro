require "test_helper"

class NoteTest < ActiveSupport::TestCase
  def setup
    @user = users(:one) # Fixture user
    @note = Note.new(title: "Sample Note", content: "This is a test", user: @user)
  end

  test "should be valid with valid attributes" do
    assert @note.valid?
  end

  test "should require content" do
    @note.content = nil
    assert_not @note.valid?
  end

  test "should belong to a user" do
    @note.user = nil
    assert_not @note.valid?
  end

  test "should filter notes by tag" do
    @second_note = notes(:one)
    tag = tags(:one)
    tag_2 = tags(:two)
    @second_note.tags << tag_2
    @second_note.save
    @note.tags << tag
    @note.save
    assert_equal [@note], Note.with_tags([tag.id])
  end
end
