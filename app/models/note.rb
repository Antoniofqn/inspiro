class Note < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  validates :content, presence: true

  accepts_nested_attributes_for :tags
end
