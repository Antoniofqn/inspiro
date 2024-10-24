class Api::V1::NotesController < Api::ApiController

  def index
    notes = current_user.notes
    render json: notes
  end

  def create
    note = current_user.notes.create!(note_params)
    render json: note, status: :created
  end

  private

  def note_params
    params.require(:note).permit(:title, :content)
  end
end