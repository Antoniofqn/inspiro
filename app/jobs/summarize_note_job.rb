class SummarizeNoteJob
  include Sidekiq::Job
  queue_as :default

  def perform(note_id)
    note = Note.find(note_id)
    note.summary = Ai::SummarizationService.new(note.content).summarize
    note.save
  end
end
