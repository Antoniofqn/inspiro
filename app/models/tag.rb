class Tag < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
