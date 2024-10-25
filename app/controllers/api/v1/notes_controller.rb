class Api::V1::NotesController < Api::ApiController
  before_action :set_note, only: %i[show update destroy]

  def index
    notes = policy_scope(Note).includes(:tags)
    render json: notes.as_json(include: :tags)
  end

  def show
    authorize @note
    render json: @note.as_json(include: :tags)
  end

  def create
    note = Note.new(note_params.merge(user: current_user))
    authorize note
    assign_user_to_tags(note)
    if note.save
      render json: note.as_json(include: :tags), status: :created
    else
      render json: note.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize @note
    assign_user_to_tags(@note)
    if @note.update(note_params)
      render json: @note.as_json(include: :tags)
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @note
    @note.destroy
  end

  private

  def set_note
    @note = current_user.notes.includes(:tags).find(params[:id])
  end

  def note_params
    params.require(:note).permit(
      :title, :content,
      tags_attributes: [:id, :name, :_destroy]
    )
  end

  def assign_user_to_tags(note)
    note.tags.each do |tag|
      tag.user_id ||= current_user.id
    end
  end
end
