class Note < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  has_many :cluster_notes, dependent: :destroy
  has_many :clusters, through: :cluster_notes

  validates :content, presence: true

  accepts_nested_attributes_for :tags

  before_save :generate_summary, if: :new_record?

  scope :with_tags, ->(tag_ids) {
    joins(:tags).where(tags: { id: tag_ids }).distinct
  }

  ##
  # Methods
  #
  def tag_names
    tags.map(&:name)
  end

  def generate_summary
    self.summary = Ai::SummarizationService.new(content).summarize
  end
end
