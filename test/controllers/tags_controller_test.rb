require "test_helper"

class Api::V1::TagsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one) # Fixture user
    @tag = tags(:one) # Fixture tag
    @headers = @user.create_new_auth_token
  end

  test "should get index" do
    get api_v1_tags_url, headers: @headers
    assert_response :success
  end

  test "should create tag" do
    assert_difference("Tag.count", 1) do
      post api_v1_tags_url,
        params: { tag: { name: "New Tag" } },
        headers: @headers
    end
    assert_response :success
  end

  test "should update tag" do
    patch api_v1_tag_url(@tag),
      params: { tag: { name: "Updated Tag" } },
      headers: @headers
    assert_response :success
    @tag.reload
    assert_equal "Updated Tag", @tag.name
  end

  test "should destroy tag" do
    assert_difference("Tag.count", -1) do
      delete api_v1_tag_url(@tag), headers: @headers
    end
    assert_response :no_content
  end
end
