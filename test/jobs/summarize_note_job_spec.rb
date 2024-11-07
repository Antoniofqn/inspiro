require 'test_helper'
require 'sidekiq/testing'
require 'minitest/autorun'

class SummarizeNoteJobTest < ActiveJob::TestCase
  fixtures :notes

  setup do
    Sidekiq::Testing.inline!
    @note = notes(:one)
    @note.update(content: "This is a test note content.")
  end

  test 'summarizes the note content' do
    mock_summarization_service = Minitest::Mock.new
    mock_summarization_service.expect :summarize, "Summarized content"

    Ai::SummarizationService.stub :new, mock_summarization_service do
      SummarizeNoteJob.new.perform(@note.id)
      @note.reload
      assert_equal "Summarized content", @note.summary
    end

    mock_summarization_service.verify
  end

  test 'saves the note with the summarized content' do
    mock_summarization_service = Minitest::Mock.new
    mock_summarization_service.expect :summarize, "Summarized content"

    Ai::SummarizationService.stub :new, mock_summarization_service do
      SummarizeNoteJob.new.perform(@note.id)
      @note.reload
      assert_equal "Summarized content", @note.summary
    end

    mock_summarization_service.verify
  end

  test 'raises an error if note is not found' do
    assert_raises(ActiveRecord::RecordNotFound) do
      SummarizeNoteJob.new.perform(-1)
    end
  end
end
