class Api::V1::ClustersController < Api::ApiController
  before_action :set_cluster, only: %i[show update destroy add_notes remove_notes]
  before_action :set_notes, only: %i[add_notes remove_notes]

  api :GET, '/clusters', 'List all clusters'
  def index
    @clusters = policy_scope(Cluster).includes(:notes)
    authorize @clusters
    render json: Api::V1::ClusterSerializer.new(@clusters)
  end

  api :GET, '/clusters/:id', 'Show a cluster'
  param :id, :number, required: true
  def show
    authorize @cluster
    render json: Api::V1::ClusterSerializer.new(@cluster)
  end

  api :POST, '/clusters', 'Create a cluster'
  param :cluster, Hash, required: true do
    param :name, String, required: true
  end
  def create
    @cluster = current_user.clusters.new(cluster_params)
    authorize @cluster
    @cluster.save!
    render json: Api::V1::ClusterSerializer.new(@cluster)
  end

  api :PATCH, '/clusters/:id', 'Update a cluster'
  param :id, :number, required: true
  param :cluster, Hash, required: true do
    param :name, String, required: true
  end
  def update
    authorize @cluster
    @cluster.update!(cluster_params)
    render json: Api::V1::ClusterSerializer.new(@cluster)
  end

  api :DELETE, '/clusters/:id', 'Delete a cluster'
  param :id, :number, required: true
  def destroy
    authorize @cluster
    @cluster.destroy
    render json: { message: 'Cluster successfully deleted' }, status: :no_content
  end

  # Add multiple notes to a cluster
  api :POST, '/clusters/:id/add_notes', 'Add notes to a cluster'
  param :id, :number, required: true
  param :note_ids, Array, required: true
  def add_notes
    authorize_cluster_with_notes!(:add_notes?)
    @cluster.notes << @notes.reject { |note| @cluster.notes.include?(note) }
    render json: Api::V1::ClusterSerializer.new(@cluster)
  end

  # Remove notes from a cluster
  api :DELETE, '/clusters/:id/remove_notes', 'Remove notes from a cluster'
  param :id, :number, required: true
  param :note_ids, Array, required: true
  def remove_notes
    authorize_cluster_with_notes!(:remove_notes?)
    @cluster.notes.delete(@notes)
    render json: Api::V1::ClusterSerializer.new(@cluster)
  end

  private

  def set_notes
    raise ActionController::ParameterMissing, "note_ids param is required" unless params[:note_ids].present?
    @notes = current_user.notes.where(id: Decoder.bulk_decode_ids(Note, params[:note_ids]))
    raise ActiveRecord::RecordNotFound, "No notes found" if @notes.empty?
  end

  def set_cluster
    @cluster = current_user.clusters.includes(:notes).find(params[:id])
  end

  def cluster_params
    params.require(:cluster).permit(:name)
  end

  def authorize_cluster_with_notes!(action)
    policy = ClusterPolicy.new(current_user, @cluster, @notes)
    unless policy.public_send(action)
      raise Pundit::NotAuthorizedError, "You are not authorized to perform this action"
    end
  end
end
