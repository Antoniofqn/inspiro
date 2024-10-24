class Api::V1::NotesController < Api::ApiController
  before_action :set_note, only: %i[show update destroy]

  def index
    notes = policy_scope(Note)
    render json: notes
  end

  def create
    note = Note.new(note_params.merge(user: current_user))
    authorize note
    if note.save
      render json: note, status: :created
    else
      render json: note.errors, status: :unprocessable_entity
    end
  end

  def show
    authorize @note
    render json: @note
  end

  def update
    authorize @note
    if @note.update(note_params)
      render json: @note
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
    @note = current_user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end
end
