class User < ApplicationRecord
  extend Devise::Models

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable

  include DeviseTokenAuth::Concerns::User
end
