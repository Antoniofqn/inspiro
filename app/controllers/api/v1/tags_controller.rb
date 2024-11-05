class Api::V1::TagsController < Api::ApiController
  before_action :set_tag, only: %i[show update destroy]

  def index
    @tags = policy_scope(Tag).includes(:notes).includes(:user)
    authorize @tags
    render json: Api::V1::TagSerializer.new(@tags)
  end

  def show
    authorize @tag
    render json: Api::V1::TagSerializer.new(@tag)
  end

  def create
    @tag = current_user.tags.new(tag_params)
    authorize @tag
    @tag.save!
    render json: Api::V1::TagSerializer.new(@tag)
  end

  def update
    authorize @tag
    @tag.update!(tag_params)
    render json: Api::V1::TagSerializer.new(@tag)
  end

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
