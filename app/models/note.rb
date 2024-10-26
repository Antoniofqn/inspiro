class Note < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  validates :content, presence: true

  accepts_nested_attributes_for :tags

  scope :with_tags, ->(tag_ids) {
    joins(:tags).where(tags: { id: tag_ids }).distinct
  }

  ##
  # Methods
  #
  def tag_names
    tags.map(&:name)
  end
end
