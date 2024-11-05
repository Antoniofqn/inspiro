require 'test_helper'

class Api::V1::ClustersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @cluster = clusters(:one) # Belongs to @user
    @other_cluster = clusters(:two) # Belongs to @other_user
    @note = notes(:one) # Belongs to @user
    @other_note = notes(:two) # Belongs to @other_user
    @headers = @user.create_new_auth_token
    @other_headers = @other_user.create_new_auth_token
  end

  test "should get index" do
    get api_v1_clusters_url, headers: @headers, as: :json
    assert_response :success
  end

  test "should show cluster" do
    get api_v1_cluster_url(@cluster), headers: @headers, as: :json
    assert_response :success
  end

  test "should not show another user's cluster" do
    get api_v1_cluster_url(@other_cluster), headers: @headers, as: :json
    assert_response :not_found
  end

  test "should create cluster" do
    assert_difference('Cluster.count') do
      post api_v1_clusters_url, params: { cluster: { name: 'New Cluster' } }, headers: @headers, as: :json
    end
    assert_response :success
  end

  test "should update cluster" do
    patch api_v1_cluster_url(@cluster), params: { cluster: { name: 'Updated Cluster' } }, headers: @headers, as: :json
    assert_response :success
  end

  test "should not update another user's cluster" do
    put api_v1_cluster_url(@other_cluster), params: { cluster: { name: 'Hacked Cluster' } }, headers: @headers, as: :json
    assert_response :not_found
  end

  test "should add notes to cluster" do
    post add_notes_api_v1_cluster_url(@cluster), params: { note_ids: [@note.hashid] }, headers: @headers, as: :json
    assert_response :success
    @cluster.reload
    assert_includes @cluster.notes, @note
  end

  test "should not add another user's notes to cluster" do
    post add_notes_api_v1_cluster_url(@cluster), params: { note_ids: [@other_note.hashid] }, headers: @headers, as: :json
    assert_response :not_found
  end

  test "should not add notes without note_ids param" do
    post add_notes_api_v1_cluster_url(@cluster), headers: @headers, as: :json
    assert_response :bad_request
  end

  test "should remove notes from cluster" do
    @cluster.notes << @note
    delete remove_notes_api_v1_cluster_url(@cluster), params: { note_ids: [@note.hashid] }, headers: @headers, as: :json
    assert_response :success
    @cluster.reload
    refute_includes @cluster.notes, @note
  end

  test "should not remove another user's notes from cluster" do
    @cluster.notes << @other_note
    delete remove_notes_api_v1_cluster_url(@cluster), params: { note_ids: [@other_note.hashid] }, headers: @headers, as: :json
    assert_response :not_found
  end

  test "should destroy cluster" do
    assert_difference('Cluster.count', -1) do
      delete api_v1_cluster_url(@cluster), headers: @headers, as: :json
    end
    assert_response :no_content
  end

  test "should not destroy another user's cluster" do
    assert_no_difference('Cluster.count') do
      delete api_v1_cluster_url(@other_cluster), headers: @headers, as: :json
    end
    assert_response :not_found
  end
end
