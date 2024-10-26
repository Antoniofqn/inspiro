class Api::V1::TagsController < Api::ApiController
  before_action :set_tag, only: %i[show update destroy]

  def index
    tags = policy_scope(Tag)
    render json: TagSerializer.new(@tags)
  end

  def show
    render json: TagSerializer.new(@tag)
  end

  def create
    tag = current_user.tags.new(tag_params)
    tag.save!
    render json: TagSerializer.new(tag)
  end

  def update
    @tag.update!(tag_params)
    render json: TagSerializer.new(@tag)
  end

  def destroy
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
