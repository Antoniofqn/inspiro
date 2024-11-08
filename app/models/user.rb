class User < ApplicationRecord
  extend Devise::Models
  include FeatureLimits

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable

  include DeviseTokenAuth::Concerns::User

  has_many :notes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :clusters, dependent: :destroy

  enum plan: { free: 0, premium: 1 }

  ##
  # Methods
  #

  def premium?
    plan == 'premium'
  end

  def can_perform_search?
    premium? || search_count < FREE_SEARCH_LIMIT
  end

  def increment_search_count
    update_column(:search_count, search_count + 1)
  end
end
