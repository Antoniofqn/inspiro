class Cluster < ApplicationRecord
  belongs_to :user
  has_many :cluster_notes, dependent: :destroy
  has_many :notes, through: :cluster_notes

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
