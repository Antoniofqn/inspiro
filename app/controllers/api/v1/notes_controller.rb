class Api::V1::NotesController < Api::ApiController
  before_action :set_note, only: %i[show update destroy]
  before_action :set_notes, only: :associate_tags

  def index
    @q = policy_scope(Note).includes(:tags)
    @q = @q.with_tags(Decoder.bulk_decode_ids(Tag, params[:tag_ids])) if params[:tag_ids].present?
    @notes = @q.page(params[:page]).per(params[:per_page])
    render json: Api::V1::NoteSerializer.new(@notes, meta: serializer_meta(@notes, @q))
  end

  def show
    authorize @note
    render json: Api::V1::NoteSerializer.new(@note)
  end

  def create
    @note = Note.new(note_params.merge(user: current_user))
    authorize @note
    assign_tags_to_note(@note)
    @note.save!
    render json: Api::V1::NoteSerializer.new(@note)
  end

  def update
    authorize @note
    assign_tags_to_note(@note)
    @note.update!(note_params.except(:tags_attributes))
    render json: Api::V1::NoteSerializer.new(@note)
  end

  def destroy
    authorize @note
    @note.destroy
    render json: { message: 'Note successfully deleted' }, status: :no_content
  end

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
