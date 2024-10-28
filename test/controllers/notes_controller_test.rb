require "test_helper"

class Api::V1::NotesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one) # Fixture user
    @note = notes(:one) # Fixture note
    @headers = @user.create_new_auth_token
  end

  test "should get index" do
    get api_v1_notes_url, headers: @headers
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
end
