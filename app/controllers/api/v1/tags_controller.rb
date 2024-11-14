class Api::V1::TagsController < Api::ApiController
  before_action :set_tag, only: %i[show update destroy]

  api :GET, '/tags', 'List all tags'
  def index
    @tags = policy_scope(Tag).includes(:notes).includes(:user)
    authorize @tags
    render json: Api::V1::TagSerializer.new(@tags)
  end

  api :GET, '/tags/:id', 'Show a tag'
  param :id, :number, required: true
  def show
    authorize @tag
    render json: Api::V1::TagSerializer.new(@tag)
  end

  api :POST, '/tags', 'Create a tag'
  param :tag, Hash, required: true do
    param :name, String, required: true
  end
  def create
    @tag = current_user.tags.new(tag_params)
    authorize @tag
    @tag.save!
    render json: Api::V1::TagSerializer.new(@tag)
  end

  api :PATCH, '/tags/:id', 'Update a tag'
  param :id, :number, required: true
  param :tag, Hash, required: true do
    param :name, String, required: true
  end
  def update
    authorize @tag
    @tag.update!(tag_params)
    render json: Api::V1::TagSerializer.new(@tag)
  end

  api :DELETE, '/tags/:id', 'Delete a tag'
  param :id, :number, required: true
  def destroy
    authorize @tag
    @tag.destroy
    render json: { message: 'Tag successfully deleted' }, status: :no_content
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
