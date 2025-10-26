class Credential < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :external_id, presence: true
  validates :external_id, uniqueness: true
  validates :public_key, presence: true
  validates :user_id, presence: true
end
