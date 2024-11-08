require "test_helper"
require 'minitest/autorun'

class Api::V1::NotesControllerTest < ActionDispatch::IntegrationTest
  include FeatureLimits

  def setup
    @user = users(:one) # Fixture user
    @note = notes(:one) # Fixture note
    @note2 = notes(:two) # Fixture note
    @headers = @user.create_new_auth_token
  end

  test "should get index" do
    get api_v1_notes_url, headers: @headers, as: :json
    assert_response :success
  end

  test "should create note" do
    assert_difference("Note.count", 1) do
      post api_v1_notes_url,
        params: { note: { title: "New Note", content: "Test content" } },
        headers: @headers
    end
    assert_response :success
  end

  test "should show note" do
    get api_v1_note_url(@note), headers: @headers
    assert_response :success
  end

  test "should update note" do
    patch api_v1_note_url(@note),
      params: { note: { title: "Updated Note" } },
      headers: @headers
    assert_response :success
    @note.reload
    assert_equal "Updated Note", @note.title
  end

  test "should destroy note" do
    assert_difference("Note.count", -1) do
      delete api_v1_note_url(@note), headers: @headers
    end
    assert_response :no_content
  end

  test "can't create over the limit if user is not premium" do
    i = 1
    FREE_NOTE_LIMIT.times do
      Note.create!(title: "Note_#{i}", content: "Content", user: @user)
      i += 1
    end
    post api_v1_notes_url, params: { note: { title: "Note_#{i}", content: "Test content" } }, headers: @headers
    assert_response :forbidden
  end

  test "should add suggested tags" do
    suggested_tags = ["tag1", "tag2"]
    post add_suggested_tags_api_v1_note_url(@note), params: { tag_names: suggested_tags }, headers: @headers, as: :json
    assert_response :success
    @note.reload
    assert_includes @note.tags.map(&:name), "tag1"
    assert_includes @note.tags.map(&:name), "tag2"
  end
end
