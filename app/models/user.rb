# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  email       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string           not null
#
class User < ApplicationRecord
  # Associations
  has_many :credentials, dependent: :destroy
  has_many :programs, dependent: :destroy
  has_many :workouts, dependent: :destroy

  # Normalization (Rails 7.1+)
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Validations
  validates :email, presence: true
  validates :email, uniqueness: {case_sensitive: false}
  validates :email, format: {with: /\A[^@\s]+@[^@\s]+\z/, message: "must be a valid email address"}

  # Callbacks
  before_create :generate_webauthn_id

  private

  def generate_webauthn_id
    self.webauthn_id = SecureRandom.hex(16)
  end
end
