class Note < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  has_many :cluster_notes, dependent: :destroy
  has_many :clusters, through: :cluster_notes

  validates :content, presence: true

  accepts_nested_attributes_for :tags

  after_save :enqueue_summarization, if: -> { saved_change_to_content? }

  scope :with_tags, ->(tag_ids) {
    joins(:tags).where(tags: { id: tag_ids }).distinct
  }

  ##
  # Methods
  #
  def tag_names
    tags.map(&:name)
  end

  def enqueue_summarization
    SummarizeNoteJob.perform_async(self.id)
  end
end
