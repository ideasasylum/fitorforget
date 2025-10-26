class User < ApplicationRecord
  # Associations
  has_many :credentials, dependent: :destroy

  # Normalization (Rails 7.1+)
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Validations
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /@/, message: "must contain @" }

  # Callbacks
  before_create :generate_webauthn_id

  # Class method for case-insensitive email lookup
  # Note: With normalizes, this could be simplified to just find_by(email:)
  # but keeping explicit method for clarity and legacy data compatibility
  def self.find_by_email(email)
    return nil if email.blank?
    # Rails normalizes will handle the normalization automatically
    find_by(email: email)
  end

  private

  def generate_webauthn_id
    self.webauthn_id = SecureRandom.hex(16)
  end
end
