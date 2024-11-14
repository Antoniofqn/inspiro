class Api::V1::NotesController < Api::ApiController
  before_action :set_note, only: %i[show update destroy tag_suggestions add_suggested_tags]
  before_action :set_notes, only: :associate_tags

  api :GET, '/notes', 'List all notes'
  param :tag_ids, Array, desc: 'Filter notes by tag ids'
  param :page, :number, desc: 'Page number'
  param :per_page, :number, desc: 'Number of notes per page'
  def index
    @q = policy_scope(Note).includes(:tags)
    @q = @q.with_tags(Decoder.bulk_decode_ids(Tag, params[:tag_ids])) if params[:tag_ids].present?
    @notes = @q.page(params[:page]).per(params[:per_page])
    render json: Api::V1::NoteSerializer.new(@notes, meta: serializer_meta(@notes, @q))
  end

  api :GET, '/notes/:id', 'Show a note'
  param :id, :number, required: true
  def show
    authorize @note
    render json: Api::V1::NoteSerializer.new(@note)
  end

  api :POST, '/notes', 'Create a note'
  param :note, Hash, required: true do
    param :title, String, required: true
    param :content, String, required: true
    param :tags_attributes, Array, desc: 'Array of tag attributes' do
      param :name, String, required: true
      param :_destroy, [true, false], desc: 'Mark tag for destruction'
    end
  end
  def create
    @note = Note.new(note_params.merge(user: current_user))
    authorize @note
    assign_tags_to_note(@note)
    @note.save!
    render json: Api::V1::NoteSerializer.new(@note)
  end

  api :PATCH, '/notes/:id', 'Update a note'
  param :id, :number, required: true
  param :note, Hash, required: true do
    param :title, String
    param :content, String
    param :tags_attributes, Array, desc: 'Array of tag names'
  end
  def update
    authorize @note
    assign_tags_to_note(@note)
    @note.update!(note_params.except(:tags_attributes))
    render json: Api::V1::NoteSerializer.new(@note)
  end

  api :DELETE, '/notes/:id', 'Delete a note'
  param :id, :number, required: true
  def destroy
    authorize @note
    @note.destroy
    render json: { message: 'Note successfully deleted' }, status: :no_content
  end

  # Add multiple tags to multiple notes
  api :POST, '/notes/associate_tags', 'Associate tags to notes'
  param :note_ids, Array, desc: 'Array of note ids', required: true
  param :tag_ids, Array, desc: 'Array of tag ids', required: true
  param :action_type, %w[add remove], desc: 'Action type', required: true
  def associate_tags
    authorize @notes
    tag_ids = params[:tag_ids] || []
    action_type = params[:action_type]
    tags = current_user.tags.where(id: Decoder.bulk_decode_ids(Tag, tag_ids))
    case action_type
    when 'add'
      @notes.each { |note| note.tags << tags.reject { |tag| note.tags.include?(tag) } }
    when 'remove'
      @notes.each { |note| note.tags.delete(tags) }
    else
      return render json: { error: 'Invalid action type' }, status: :unprocessable_entity
    end
    render json: Api::V1::NoteSerializer.new(@notes)
  end

  # related to AI service
  api :GET, '/notes/:id/tag_suggestions', 'Get tag suggestions for a note'
  param :id, :number, required: true
  def tag_suggestions
    authorize @note
    suggested_tags = Ai::TagSuggestionService.new(@note).suggest_tags
    render json: { suggested_tags: suggested_tags }, status: :ok
  end

  # related to AI service
  api :POST, '/notes/:id/add_suggested_tags', 'Add suggested tags to a note'
  param :id, :number, required: true
  param :tag_names, Array, desc: 'Array of tag names', required: true
  def add_suggested_tags
    authorize @note
    tag_names = params[:tag_names] || []
    tag_names.each do |name|
      tag = current_user.tags.find_or_create_by!(name: name)
      @note.tags << tag unless @note.tags.include?(tag)
    end
    render json: Api::V1::NoteSerializer.new(@note)
  end

  # related to AI service
  api :GET, '/notes/semantic_search', 'Search notes using semantic search'
  param :query, String, required: true
  param :page, :number, desc: 'Page number'
  param :per_page, :number, desc: 'Number of notes per page'
  def semantic_search
    authorize Note
    query = params[:query]
    @q = Ai::SemanticSearchService.new(query, current_user).search_notes
    @notes = @q.page(params[:page]).per(params[:per_page])
    render json: Api::V1::NoteSerializer.new(@results, meta: serializer_meta(@notes, @q) )
  end

  private

  def set_notes
    @notes = policy_scope(Note).where(id: Decoder.bulk_decode_ids(Note, params[:note_ids])).includes(:tags)
  end

  def set_note
    @note = current_user.notes.includes(:tags).find(params[:id])
  end

  def note_params
    params.require(:note).permit(
      :title, :content,
      tags_attributes: [:id, :name, :_destroy]
    )
  end

  def assign_tags_to_note(note)
    return unless params[:note][:tags_attributes].present?

    tag_names = params[:note][:tags_attributes].map { |tag| tag[:name] }
    tags = tag_names.map do |name|
      current_user.tags.find_or_create_by!(name: name)
    end
    note.tags = tags
  end
end
