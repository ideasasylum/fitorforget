class User < ApplicationRecord
  # Associations
  has_many :credentials, dependent: :destroy

  # Validations
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /@/, message: "must contain @" }

  # Callbacks
  before_create :generate_webauthn_id

  private

  def generate_webauthn_id
    self.webauthn_id = SecureRandom.hex(16)
  end
end
